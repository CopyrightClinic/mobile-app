import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_back_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/utils/ui/snackbar_utils.dart';
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';
import 'package:copyright_clinic_flutter/core/utils/password_strength.dart';
import 'package:copyright_clinic_flutter/core/widgets/password_strength_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../di.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;
  void Function(void Function())? _passwordState;
  void Function(void Function())? _confirmPasswordState;

  PasswordStrengthResult? _passwordStrength;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final passwordValidation = validatePassword(newPassword, tr, isLogin: false);
    final confirmPasswordValidation = _validateConfirmPassword(newPassword, confirmPassword, tr);

    return passwordValidation == null && confirmPasswordValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      context.read<AuthBloc>().add(
        ResetPasswordRequested(email: widget.email, otp: widget.otp, newPassword: newPassword, confirmPassword: confirmPassword),
      );

      _confirmPasswordFocusNode.unfocus();
    }
  }

  String? _validateConfirmPassword(String? password, String? confirmPassword, String Function(String) tr) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return tr(AppStrings.confirmPasswordIsRequired);
    } else if (password != confirmPassword) {
      return tr(AppStrings.passwordsDoNotMatch);
    }
    return null;
  }

  void _handlePasswordChange(String value) {
    if (value.isEmpty) {
      _passwordStrength = null;
      _buttonSetState?.call(() {});
      _passwordState?.call(() {});
    } else {
      if (_confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text != value) {
        _confirmPasswordState?.call(() {});
        _buttonSetState?.call(() {});
      }
      if (_confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text == value) {
        _confirmPasswordState?.call(() {});
        _buttonSetState?.call(() {});
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordStrength = PasswordStrengthHelper.evaluatePasswordStrength(value);
        _buttonSetState?.call(() {});
        _passwordState?.call(() {});
      });
    }
  }

  void _handleConfirmPasswordChange(String value) {
    if (value.isNotEmpty && _newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text.trim() == value) {
        _buttonSetState?.call(() {});
      } else {
        _buttonSetState?.call(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          SnackBarUtils.showSuccess(context, state.message);
          context.pop();
          context.pop();
        } else if (state is ResetPasswordError) {
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(padding: EdgeInsets.only(left: DimensionConstants.gap8Px.w), child: const CustomBackButton()),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: DimensionConstants.gap20Px.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: DimensionConstants.gap20Px.h),
                          TranslatedText(
                            AppStrings.resetPasswordTitle,
                            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font32Px.f, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: DimensionConstants.gap4Px.h),
                          TranslatedText(
                            AppStrings.setNewPassword,
                            style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: DimensionConstants.gap40Px.h),
                          StatefulBuilder(
                            builder: (context, state) {
                              _passwordState = state;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    label: AppStrings.newPassword,
                                    placeholder: AppStrings.enterNewPassword,
                                    controller: _newPasswordController,
                                    focusNode: _newPasswordFocusNode,
                                    isPassword: true,
                                    validator: (value) => validatePassword(value, tr, isLogin: false),
                                    onEditingComplete: () => _confirmPasswordFocusNode.requestFocus(),
                                    onChanged: (value) {
                                      _onFieldChanged();
                                      _handlePasswordChange(value);
                                    },
                                  ),
                                  PasswordStrengthIndicator(passwordStrength: _passwordStrength, isVisible: _newPasswordController.text.isNotEmpty),
                                ],
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
                                validator: (value) => _validateConfirmPassword(_newPasswordController.text.trim(), value, tr),
                                onEditingComplete: () => _confirmPasswordFocusNode.unfocus(),
                                onChanged: (value) {
                                  _onFieldChanged();
                                  _handleConfirmPasswordChange(value);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    bloc: sl<AuthBloc>(),
                    builder: (context, state) {
                      final isLoading = state is ResetPasswordLoading;

                      return StatefulBuilder(
                        builder: (context, setState) {
                          _buttonSetState = setState;
                          return AuthButton(
                            text: AppStrings.updatePassword,
                            onPressed: _handleResetPassword,
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
    );
  }
}
