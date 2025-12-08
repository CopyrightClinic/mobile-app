import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_back_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_app_bar.dart';
import 'package:copyright_clinic_flutter/core/utils/ui/snackbar_utils.dart';
import 'package:copyright_clinic_flutter/core/utils/password_strength.dart';
import 'package:copyright_clinic_flutter/di.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;
  void Function(void Function())? _passwordState;
  void Function(void Function())? _confirmPasswordState;

  String? _passwordError;
  String? _confirmPasswordError;
  PasswordStrengthResult? _passwordStrength;
  PasswordStrengthResult? _confirmPasswordStrength;

  @override
  void initState() {
    super.initState();
    _newPasswordFocusNode.addListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.addListener(_onConfirmPasswordFocusChange);
  }

  @override
  void dispose() {
    _newPasswordFocusNode.removeListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.removeListener(_onConfirmPasswordFocusChange);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) return false;

    if (currentPassword == newPassword) return false;

    final strength = PasswordStrengthHelper.evaluatePasswordStrength(newPassword);

    return strength.strength != PasswordStrengthEnum.weak && newPassword == confirmPassword;
  }

  void _onPasswordFocusChange() {
    if (!_newPasswordFocusNode.hasFocus) {
      _validatePassword();
    }
  }

  void _onConfirmPasswordFocusChange() {
    if (!_confirmPasswordFocusNode.hasFocus) {
      _validateConfirmPassword();
    }
  }

  void _validatePassword() {
    if (_newPasswordController.text.isEmpty) return;

    if (_newPasswordController.text.contains(' ')) {
      _passwordState?.call(() {
        _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.passwordNoSpaces));
        _passwordError = tr(AppStrings.passwordNoSpaces);
      });
    } else if (_currentPasswordController.text.isNotEmpty && _newPasswordController.text == _currentPasswordController.text) {
      _passwordState?.call(() {
        _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.newPasswordMustBeDifferent));
        _passwordError = tr(AppStrings.newPasswordMustBeDifferent);
      });
    } else {
      final strength = PasswordStrengthHelper.evaluatePasswordStrength(_newPasswordController.text);
      _passwordState?.call(() {
        _passwordStrength = strength;
        _passwordError = strength.strength == PasswordStrengthEnum.weak ? tr(AppStrings.passwordIsRequired) : null;
      });
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) return;

    if (_confirmPasswordController.text != _newPasswordController.text) {
      _confirmPasswordState?.call(() {
        _confirmPasswordError = tr(AppStrings.passwordsDoNotMatch);
        _confirmPasswordStrength = null;
      });
    } else {
      _confirmPasswordState?.call(() {
        _confirmPasswordError = null;
        _confirmPasswordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.matched, message: tr('matchPassword'));
      });
    }
  }

  void _handlePasswordChange(String value) {
    if (value.isEmpty) {
      _passwordError = null;
      _passwordStrength = null;
      _buttonSetState?.call(() {});
      _passwordState?.call(() {});
    } else {
      if (_confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text != value) {
        _confirmPasswordState?.call(() {
          _confirmPasswordError = tr(AppStrings.passwordsDoNotMatch);
          _confirmPasswordStrength = null;
        });
        _buttonSetState?.call(() {});
      }
      if (_confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text == value) {
        _confirmPasswordState?.call(() {
          _confirmPasswordError = null;
          _confirmPasswordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.matched, message: tr('matchPassword'));
        });
        _buttonSetState?.call(() {});
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentPasswordController.text.isNotEmpty && value == _currentPasswordController.text) {
          _passwordError = tr(AppStrings.newPasswordMustBeDifferent);
          _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.newPasswordMustBeDifferent));
        } else {
          _passwordError = null;
          _passwordStrength = PasswordStrengthHelper.evaluatePasswordStrength(value);
        }
        _buttonSetState?.call(() {});
        _passwordState?.call(() {});
      });
    }
  }

  void _handleCurrentPasswordChange(String value) {
    if (_newPasswordController.text.isNotEmpty) {
      _passwordState?.call(() {});
    }
    _buttonSetState?.call(() {});
  }

  void _handleConfirmPasswordChange(String value) {
    if (value.isEmpty) {
      _confirmPasswordError = null;
      _confirmPasswordStrength = null;
      _buttonSetState?.call(() {});
      _confirmPasswordState?.call(() {});
    } else if (value != _newPasswordController.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confirmPasswordError = tr(AppStrings.passwordsDoNotMatch);
        _confirmPasswordStrength = null;
        _buttonSetState?.call(() {});
        _confirmPasswordState?.call(() {});
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confirmPasswordError = null;
        _confirmPasswordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.matched, message: tr('matchPassword'));
        _buttonSetState?.call(() {});
        _confirmPasswordState?.call(() {});
      });
    }
  }

  Color _getPasswordBorderColor() {
    if (_passwordError != null || _passwordStrength?.strength == PasswordStrengthEnum.weak) {
      return context.red;
    }
    if (_passwordStrength?.strength == PasswordStrengthEnum.medium) {
      return _passwordStrength!.strength.color;
    }
    if (_passwordStrength?.strength == PasswordStrengthEnum.strong) {
      return _passwordStrength!.strength.color;
    }
    return context.primaryColor;
  }

  Color _getConfirmPasswordBorderColor() {
    if (_confirmPasswordError != null) {
      return context.red;
    }
    if (_confirmPasswordStrength?.strength == PasswordStrengthEnum.matched) {
      return _confirmPasswordStrength!.strength.color;
    }
    return context.primaryColor;
  }

  void _handleChangePassword() {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      return;
    }

    if (newPassword.isEmpty) {
      _passwordState?.call(() {
        _passwordError = tr(AppStrings.passwordIsRequired);
        _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.passwordIsRequired));
      });
      return;
    }

    if (newPassword == currentPassword) {
      _passwordState?.call(() {
        _passwordError = tr(AppStrings.newPasswordMustBeDifferent);
        _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.newPasswordMustBeDifferent));
      });
      return;
    }

    if (PasswordStrengthHelper.evaluatePasswordStrength(newPassword).strength == PasswordStrengthEnum.weak) {
      return;
    }

    if (confirmPassword != newPassword) {
      _confirmPasswordState?.call(() {
        _confirmPasswordError = tr(AppStrings.passwordsDoNotMatch);
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordState?.call(() {
        _confirmPasswordError = tr(AppStrings.confirmPasswordIsRequired);
      });
      return;
    }

    context.read<ProfileBloc>().add(ChangePasswordRequested(currentPassword: currentPassword, newPassword: newPassword));

    _currentPasswordFocusNode.unfocus();
    _newPasswordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProfileBloc>(),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            SnackBarUtils.showSuccess(context, state.message);
            context.pop();
          } else if (state is ChangePasswordError) {
            SnackBarUtils.showError(context, state.message);
          }
        },
        child: CustomScaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
            leading: const CustomBackButton(),
            title: TranslatedText(
              AppStrings.changePassword,
              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DimensionConstants.gap20Px.h),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: DimensionConstants.gap20Px.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              label: AppStrings.currentPassword,
                              placeholder: AppStrings.enterYourCurrentPassword,
                              controller: _currentPasswordController,
                              focusNode: _currentPasswordFocusNode,
                              isPassword: true,
                              onEditingComplete: () => _newPasswordFocusNode.requestFocus(),
                              onChanged: _handleCurrentPasswordChange,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),
                            StatefulBuilder(
                              builder: (context, state) {
                                _passwordState = state;
                                return CustomTextField(
                                  label: AppStrings.setNewPassword,
                                  placeholder: AppStrings.setNewPassword,
                                  controller: _newPasswordController,
                                  focusNode: _newPasswordFocusNode,
                                  isPassword: true,
                                  passwordStrength: _passwordStrength,
                                  errorText: _passwordError,
                                  focusedBorderColor: _getPasswordBorderColor(),
                                  onEditingComplete: () => _confirmPasswordFocusNode.requestFocus(),
                                  onChanged: _handlePasswordChange,
                                  autovalidateMode: AutovalidateMode.disabled,
                                );
                              },
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),
                            StatefulBuilder(
                              builder: (context, state) {
                                _confirmPasswordState = state;
                                return CustomTextField(
                                  label: AppStrings.confirmPassword,
                                  placeholder: AppStrings.confirmPassword,
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocusNode,
                                  isPassword: true,
                                  passwordStrength: _confirmPasswordStrength,
                                  errorText: _confirmPasswordError,
                                  focusedBorderColor: _getConfirmPasswordBorderColor(),
                                  onEditingComplete: _handleChangePassword,
                                  onChanged: _handleConfirmPasswordChange,
                                  autovalidateMode: AutovalidateMode.disabled,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      bloc: sl<ProfileBloc>(),
                      builder: (context, state) {
                        final isLoading = state is ChangePasswordLoading;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            _buttonSetState = setState;
                            return AuthButton(
                              text: AppStrings.saveChanges,
                              onPressed: _handleChangePassword,
                              isLoading: isLoading,
                              isEnabled: _isFormValid,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
