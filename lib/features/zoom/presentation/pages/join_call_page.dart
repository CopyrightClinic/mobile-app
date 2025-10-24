import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/services/zoom_service.dart';
import '../../../../core/utils/enumns/ui/zoom_meeting_status.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../di.dart';

class JoinCallPage extends StatefulWidget {
  final String? meetingNumber;
  final String? passcode;
  final String? displayName;

  const JoinCallPage({super.key, this.meetingNumber, this.passcode, this.displayName});

  @override
  State<JoinCallPage> createState() => _JoinCallPageState();
}

class _JoinCallPageState extends State<JoinCallPage> {
  final _formKey = GlobalKey<FormState>();
  final _meetingNumberController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _displayNameController = TextEditingController();

  final ZoomService _zoomService = sl<ZoomService>();

  ZoomMeetingStatus _currentStatus = ZoomMeetingStatus.idle;
  String? _statusMessage;
  bool _isJoining = false;
  bool _permissionsGranted = false;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _meetingNumberController.text = widget.meetingNumber ?? '';
    _passcodeController.text = widget.passcode ?? '';
    _displayNameController.text = widget.displayName ?? '';

    _checkPermissions();
    _listenToMeetingEvents();
  }

  @override
  void dispose() {
    _meetingNumberController.dispose();
    _passcodeController.dispose();
    _displayNameController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      setState(() {
        _permissionsGranted = cameraStatus.isGranted && microphoneStatus.isGranted;
      });
    } catch (e) {
      Log.e('JoinCallPage', 'Error checking permissions: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final permissions = <Permission>[Permission.camera, Permission.microphone];

      if (Platform.isAndroid) {
        final androidVersion = int.tryParse(Platform.version.split('.').first) ?? 0;
        if (androidVersion >= 31) {
          permissions.add(Permission.bluetoothConnect);
        }
        if (androidVersion >= 33) {
          permissions.add(Permission.notification);
        }
      }

      final statuses = await permissions.request();

      final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

      setState(() {
        _permissionsGranted = cameraGranted && micGranted;
      });

      if (!_permissionsGranted) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      }
    } catch (e) {
      Log.e('JoinCallPage', 'Error requesting permissions: $e');
      if (mounted) {
        SnackBarUtils.showError(context, '${AppStrings.permissionDenied}: $e'.tr());
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: TranslatedText(
              AppStrings.permissionsNeeded,
              style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.bold),
            ),
            content: TranslatedText(AppStrings.cameraAndMicrophoneRequired, style: TextStyle(fontSize: DimensionConstants.font14Px.f)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: TranslatedText(AppStrings.cancel, style: TextStyle(fontSize: DimensionConstants.font14Px.f)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: TranslatedText(AppStrings.openSettings, style: TextStyle(fontSize: DimensionConstants.font14Px.f)),
              ),
            ],
          ),
    );
  }

  void _listenToMeetingEvents() {
    _zoomService.listenToMeetingEvents(
      onStatusChanged: (status, message) {
        if (mounted) {
          setState(() {
            _currentStatus = status;
            _statusMessage = message;

            if (status.isFinished || status.isError) {
              _isJoining = false;
            }
          });

          if (status == ZoomMeetingStatus.ended) {
            SnackBarUtils.showError(context, AppStrings.zoomMeetingEnded.tr());
          } else if (status == ZoomMeetingStatus.failed && message != null) {
            SnackBarUtils.showError(context, message);
          }
        }
      },
    );
  }

  Future<void> _joinMeeting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_permissionsGranted) {
      await _requestPermissions();
      if (!_permissionsGranted) {
        return;
      }
    }

    setState(() {
      _isJoining = true;
    });

    try {
      await _zoomService.joinMeeting(
        meetingNumber: _meetingNumberController.text.trim(),
        passcode: _passcodeController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );
    } on PlatformException catch (e) {
      Log.e('JoinCallPage', 'Platform exception: ${e.code} - ${e.message}');

      if (mounted) {
        String errorMessage = AppStrings.zoomErrorJoinFailed.tr();

        switch (e.code) {
          case 'NETWORK_UNAVAILABLE':
            errorMessage = AppStrings.zoomErrorNetworkUnavailable.tr();
            break;
          case 'INVALID_ARGUMENTS':
            errorMessage = AppStrings.zoomErrorInvalidMeetingNumber.tr();
            break;
          case 'JWT_INVALID':
            errorMessage = AppStrings.zoomErrorJwtInvalid.tr();
            break;
          default:
            if (e.message != null) {
              errorMessage = e.message!;
            }
        }

        SnackBarUtils.showError(context, errorMessage);
        setState(() {
          _isJoining = false;
        });
      }
    } catch (e) {
      Log.e('JoinCallPage', 'Error joining meeting: $e');

      if (mounted) {
        SnackBarUtils.showError(context, '${AppStrings.zoomErrorJoinFailed}: $e'.tr());
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  Future<void> _leaveMeeting() async {
    try {
      await _zoomService.leaveMeeting();
      if (mounted) {
        setState(() {
          _isJoining = false;
          _currentStatus = ZoomMeetingStatus.idle;
        });
      }
    } catch (e) {
      Log.e('JoinCallPage', 'Error leaving meeting: $e');
      if (mounted) {
        SnackBarUtils.showError(context, 'Failed to leave meeting: $e');
      }
    }
  }

  String? _validateMeetingNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterMeetingNumber.tr();
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 9) {
      return AppStrings.zoomErrorInvalidMeetingNumber.tr();
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterDisplayName.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        leading: CustomBackButton(
          onPressed: () {
            if (_currentStatus.isActive || _currentStatus.isWaiting) {
              _showLeaveConfirmationDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: TranslatedText(AppStrings.joinMeeting, style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DimensionConstants.gap20Px.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_currentStatus != ZoomMeetingStatus.idle) ...[_buildStatusBanner(), SizedBox(height: DimensionConstants.gap20Px.h)],

                if (!_permissionsGranted) ...[_buildPermissionWarning(), SizedBox(height: DimensionConstants.gap20Px.h)],

                CustomTextField(
                  controller: _meetingNumberController,
                  label: AppStrings.meetingNumber.tr(),
                  placeholder: AppStrings.enterMeetingNumber.tr(),
                  keyboardType: TextInputType.number,
                  validator: _validateMeetingNumber,
                  readOnly: _isJoining || !_currentStatus.isFinished,
                ),
                SizedBox(height: DimensionConstants.gap16Px.h),

                CustomTextField(
                  controller: _passcodeController,
                  label: AppStrings.meetingPasscode.tr(),
                  placeholder: AppStrings.enterMeetingPasscode.tr(),
                  readOnly: _isJoining || !_currentStatus.isFinished,
                ),
                SizedBox(height: DimensionConstants.gap16Px.h),

                CustomTextField(
                  controller: _displayNameController,
                  label: AppStrings.displayName.tr(),
                  placeholder: AppStrings.enterDisplayName.tr(),
                  validator: _validateDisplayName,
                  readOnly: _isJoining || !_currentStatus.isFinished,
                ),
                SizedBox(height: DimensionConstants.gap32Px.h),

                if (_currentStatus.isActive || _currentStatus.isWaiting || _currentStatus.isConnecting)
                  CustomButton(
                    onPressed: _leaveMeeting,
                    backgroundColor: context.red,
                    child: TranslatedText(
                      AppStrings.leaveCall,
                      style: TextStyle(fontSize: DimensionConstants.font16Px.f, color: AppTheme.white, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  CustomButton(
                    onPressed: _isJoining ? null : _joinMeeting,
                    isLoading: _isJoining,
                    child: TranslatedText(
                      AppStrings.joinCall,
                      style: TextStyle(fontSize: DimensionConstants.font16Px.f, color: AppTheme.white, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(
        color: _currentStatus.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
        border: Border.all(color: _currentStatus.statusColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getStatusIcon(), color: _currentStatus.statusColor, size: DimensionConstants.icon24Px.r),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: TranslatedText(
                  _currentStatus.displayName,
                  style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.bold, color: _currentStatus.statusColor),
                ),
              ),
            ],
          ),
          if (_statusMessage != null) ...[
            SizedBox(height: DimensionConstants.gap8Px.h),
            TranslatedText(_statusMessage!, style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.textBody)),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(
        color: context.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
        border: Border.all(color: context.orange, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: context.orange, size: DimensionConstants.icon24Px.r),
          SizedBox(width: DimensionConstants.gap12Px.w),
          Expanded(
            child: TranslatedText(
              AppStrings.pleaseGrantPermissions,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.textBody),
            ),
          ),
          TextButton(
            onPressed: _requestPermissions,
            child: TranslatedText(
              AppStrings.grantPermissions,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case ZoomMeetingStatus.connecting:
      case ZoomMeetingStatus.reconnecting:
        return Icons.sync;
      case ZoomMeetingStatus.waitingForHost:
      case ZoomMeetingStatus.inWaitingRoom:
        return Icons.hourglass_empty;
      case ZoomMeetingStatus.inMeeting:
        return Icons.videocam;
      case ZoomMeetingStatus.failed:
      case ZoomMeetingStatus.locked:
      case ZoomMeetingStatus.authExpired:
        return Icons.error;
      case ZoomMeetingStatus.ended:
        return Icons.call_end;
      default:
        return Icons.info;
    }
  }

  void _showLeaveConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: TranslatedText(AppStrings.leaveMeeting, style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.bold)),
            content: TranslatedText('Are you sure you want to leave the meeting?', style: TextStyle(fontSize: DimensionConstants.font14Px.f)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: TranslatedText(AppStrings.cancel, style: TextStyle(fontSize: DimensionConstants.font14Px.f)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _leaveMeeting();
                  Navigator.of(context).pop();
                },
                child: TranslatedText(
                  AppStrings.leaveCall,
                  style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }
}
