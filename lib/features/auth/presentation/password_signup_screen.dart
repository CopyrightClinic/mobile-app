import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_app_bar.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_back_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/utils/ui/snackbar_utils.dart';
import 'package:copyright_clinic_flutter/core/utils/password_strength.dart';
import 'package:copyright_clinic_flutter/core/services/fcm_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../di.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class PasswordSignupScreen extends StatefulWidget {
  final String email;

  const PasswordSignupScreen({super.key, required this.email});

  @override
  State<PasswordSignupScreen> createState() => _PasswordSignupScreenState();
}

class _PasswordSignupScreenState extends State<PasswordSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
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
    _passwordFocusNode.addListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.addListener(_onConfirmPasswordFocusChange);
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.removeListener(_onConfirmPasswordFocusChange);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) return false;

    final strength = PasswordStrengthHelper.evaluatePasswordStrength(password);

    return strength.strength != PasswordStrengthEnum.weak && password == confirmPassword;
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocusNode.hasFocus) {
      _validatePassword();
    }
  }

  void _onConfirmPasswordFocusChange() {
    if (!_confirmPasswordFocusNode.hasFocus) {
      _validateConfirmPassword();
    }
  }

  void _validatePassword() {
    if (_passwordController.text.isEmpty) return;

    if (_passwordController.text.contains(' ')) {
      _passwordState?.call(() {
        _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.passwordNoSpaces));
        _passwordError = tr(AppStrings.passwordNoSpaces);
      });
    } else {
      final strength = PasswordStrengthHelper.evaluatePasswordStrength(_passwordController.text);
      _passwordState?.call(() {
        _passwordStrength = strength;
        _passwordError = strength.strength == PasswordStrengthEnum.weak ? tr(AppStrings.passwordIsRequired) : null;
      });
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) return;

    if (_confirmPasswordController.text != _passwordController.text) {
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
        _passwordError = null;
        _passwordStrength = PasswordStrengthHelper.evaluatePasswordStrength(value);
        _buttonSetState?.call(() {});
        _passwordState?.call(() {});
      });
    }
  }

  void _handleConfirmPasswordChange(String value) {
    if (value.isEmpty) {
      _confirmPasswordError = null;
      _confirmPasswordStrength = null;
      _buttonSetState?.call(() {});
      _confirmPasswordState?.call(() {});
    } else if (value != _passwordController.text) {
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

  void _handleSignUp() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      _passwordState?.call(() {
        _passwordError = tr(AppStrings.passwordIsRequired);
        _passwordStrength = PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: tr(AppStrings.passwordIsRequired));
      });
      return;
    }

    if (PasswordStrengthHelper.evaluatePasswordStrength(password).strength == PasswordStrengthEnum.weak) {
      return;
    }

    if (confirmPassword != password) {
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

    context.read<AuthBloc>().add(SignupRequested(email: widget.email, password: password, confirmPassword: confirmPassword));

    _confirmPasswordFocusNode.unfocus();
  }

  void _navigateToSignUp() {
    context.pop();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToSignUp();
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        bloc: sl<AuthBloc>(),
        listener: (context, state) {
          if (state is SignupSuccess) {
            SnackBarUtils.showSuccess(context, state.message);
            sl<FCMService>().initialize();
            context.go(AppRoutes.signupSuccessRouteName);
          } else if (state is SignupError) {
            SnackBarUtils.showError(context, state.message);
          }
        },
        child: CustomScaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            leading: Padding(padding: EdgeInsets.only(left: DimensionConstants.gap4Px.w), child: CustomBackButton(onPressed: _navigateToSignUp)),
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
                              AppStrings.createAccount,
                              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: DimensionConstants.gap4Px.h),
                            TranslatedText(
                              AppStrings.createYourAccount,
                              style: TextStyle(
                                color: context.darkTextSecondary,
                                fontSize: DimensionConstants.font14Px.f,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),
                            CustomTextField(
                              label: AppStrings.email,
                              placeholder: AppStrings.enterYourEmail,
                              initialValue: widget.email,
                              readOnly: true,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: DimensionConstants.gap20Px.h),
                            StatefulBuilder(
                              builder: (context, state) {
                                _passwordState = state;
                                return CustomTextField(
                                  label: AppStrings.password,
                                  placeholder: AppStrings.enterYourPassword,
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
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
                                  onEditingComplete: () => _confirmPasswordFocusNode.unfocus(),
                                  onChanged: _handleConfirmPasswordChange,
                                  autovalidateMode: AutovalidateMode.disabled,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is SignupLoading;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            _buttonSetState = setState;
                            return AuthButton(text: AppStrings.signUp, onPressed: _handleSignUp, isLoading: isLoading, isEnabled: _isFormValid);
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
