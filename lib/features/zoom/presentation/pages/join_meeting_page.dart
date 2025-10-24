import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/enumns/ui/zoom_meeting_status.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../di.dart';
import '../bloc/zoom_bloc.dart';
import '../bloc/zoom_event.dart';
import '../bloc/zoom_state.dart';

class JoinMeetingPage extends StatelessWidget {
  final String meetingId;

  const JoinMeetingPage({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ZoomBloc>()..add(JoinMeetingWithId(meetingId: meetingId)),
      child: JoinMeetingView(meetingId: meetingId),
    );
  }
}

class JoinMeetingView extends StatelessWidget {
  final String meetingId;

  const JoinMeetingView({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZoomBloc, ZoomState>(
      listener: (context, state) {
        if (state is ZoomMeetingFailed) {
          SnackBarUtils.showError(context, state.message);
          context.pop();
        } else if (state is ZoomMeetingEnded) {
          if (state.message != null) {
            SnackBarUtils.showSuccess(context, state.message!);
          }
          context.pop();
        }
      },
      child: CustomScaffold(
        appBar: CustomAppBar(
          leading: CustomBackButton(
            onPressed: () {
              final state = context.read<ZoomBloc>().state;
              if (state is ZoomMeetingActive) {
                _showLeaveConfirmationDialog(context);
              } else {
                context.pop();
              }
            },
          ),
          title: TranslatedText(AppStrings.joiningSession, style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child: BlocBuilder<ZoomBloc, ZoomState>(
            builder: (context, state) {
              if (state is ZoomFetchingCredentials) {
                return _buildLoadingState(context, AppStrings.loadingMeetingDetails);
              } else if (state is ZoomInitializing) {
                return _buildLoadingState(context, AppStrings.zoomInitializing);
              } else if (state is ZoomJoining) {
                return _buildLoadingState(context, AppStrings.connectingToMeeting);
              } else if (state is ZoomMeetingActive) {
                return _buildMeetingActiveState(context, state);
              } else {
                return _buildLoadingState(context, AppStrings.pleaseWait);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.primary),
          SizedBox(height: DimensionConstants.gap24Px.h),
          TranslatedText(
            message,
            style: TextStyle(fontSize: DimensionConstants.font16Px.f, color: context.darkTextPrimary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingActiveState(BuildContext context, ZoomMeetingActive state) {
    String statusMessage;
    IconData statusIcon;
    Color statusColor;

    if (state.status == ZoomMeetingStatus.inMeeting) {
      statusMessage = AppStrings.zoomStatusInMeeting;
      statusIcon = Icons.videocam;
      statusColor = context.neonGreen;
    } else if (state.status == ZoomMeetingStatus.waitingForHost) {
      statusMessage = AppStrings.zoomStatusWaitingForHost;
      statusIcon = Icons.hourglass_empty;
      statusColor = context.orange;
    } else if (state.status == ZoomMeetingStatus.inWaitingRoom) {
      statusMessage = AppStrings.zoomStatusInWaitingRoom;
      statusIcon = Icons.meeting_room;
      statusColor = context.orange;
    } else if (state.status == ZoomMeetingStatus.connecting) {
      statusMessage = AppStrings.zoomStatusConnecting;
      statusIcon = Icons.connecting_airports;
      statusColor = context.neonBlue;
    } else {
      statusMessage = state.status.name;
      statusIcon = Icons.info_outline;
      statusColor = context.darkTextSecondary;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, size: 64, color: statusColor),
            SizedBox(height: DimensionConstants.gap24Px.h),
            TranslatedText(
              statusMessage,
              style: TextStyle(fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
              textAlign: TextAlign.center,
            ),
            if (state.message != null) ...[
              SizedBox(height: DimensionConstants.gap16Px.h),
              Text(
                state.message!,
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLeaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: TranslatedText(AppStrings.leaveMeeting),
            content: TranslatedText(AppStrings.areYouSureYouWantToLeaveMeeting),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: TranslatedText(AppStrings.cancel)),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<ZoomBloc>().add(const LeaveMeetingRequested());
                },
                child: TranslatedText(AppStrings.leave),
              ),
            ],
          ),
    );
  }
}
