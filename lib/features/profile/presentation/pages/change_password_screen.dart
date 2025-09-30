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
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';
import 'package:copyright_clinic_flutter/core/utils/password_strength.dart';
import 'package:copyright_clinic_flutter/core/widgets/password_strength_indicator.dart';
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

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with Validator {
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

  PasswordStrengthResult? _passwordStrength;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final currentPasswordValidation = validatePassword(currentPassword, tr, isLogin: true);
    final newPasswordValidation = _validateNewPassword(currentPassword, newPassword, tr);
    final confirmPasswordValidation = _validateConfirmPassword(newPassword, confirmPassword, tr);

    return currentPasswordValidation == null && newPasswordValidation == null && confirmPasswordValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();

      context.read<ProfileBloc>().add(ChangePasswordRequested(currentPassword: currentPassword, newPassword: newPassword));

      _currentPasswordFocusNode.unfocus();
      _newPasswordFocusNode.unfocus();
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

  String? _validateNewPassword(String? currentPassword, String? newPassword, String Function(String) tr) {
    final standardValidation = validatePassword(newPassword, tr, isLogin: false);
    if (standardValidation != null) {
      return standardValidation;
    }

    if (currentPassword != null && currentPassword.isNotEmpty && newPassword == currentPassword) {
      return tr(AppStrings.newPasswordMustBeDifferent);
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

  void _handleCurrentPasswordChange(String value) {
    if (_newPasswordController.text.isNotEmpty) {
      _passwordState?.call(() {});
    }
    _onFieldChanged();
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
                              validator: (value) => validatePassword(value, tr, isLogin: true),
                              onEditingComplete: () => _newPasswordFocusNode.requestFocus(),
                              onChanged: (value) => _handleCurrentPasswordChange(value),
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),

                            StatefulBuilder(
                              builder: (context, state) {
                                _passwordState = state;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      label: AppStrings.setNewPassword,
                                      placeholder: AppStrings.setNewPassword,
                                      controller: _newPasswordController,
                                      focusNode: _newPasswordFocusNode,
                                      isPassword: true,
                                      validator: (value) => _validateNewPassword(_currentPasswordController.text.trim(), value, tr),
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
                                  onEditingComplete: _handleChangePassword,
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
