import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_back_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';
import 'package:copyright_clinic_flutter/core/utils/password_strength.dart';
import 'package:copyright_clinic_flutter/core/widgets/password_strength_indicator.dart';
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

class _PasswordSignupScreenState extends State<PasswordSignupScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;
  void Function(void Function())? _passwordState;
  void Function(void Function())? _confirmPasswordState;

  PasswordStrengthResult? _passwordStrength;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final passwordValidation = validatePassword(password, tr, isLogin: false);
    final confirmPasswordValidation = _validateConfirmPassword(password, confirmPassword, tr);

    return passwordValidation == null && confirmPasswordValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      context.read<AuthBloc>().add(SignupRequested(email: widget.email, password: password, confirmPassword: confirmPassword));

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
    if (value.isNotEmpty && _passwordController.text.isNotEmpty) {
      if (_passwordController.text.trim() == value) {
        _buttonSetState?.call(() {});
      } else {
        _buttonSetState?.call(() {});
      }
    }
  }

  void _navigateToWelcome() {
    context.go(AppRoutes.welcomeRouteName);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToWelcome();
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        bloc: sl<AuthBloc>(),
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green, duration: const Duration(seconds: 3)));
            context.go(AppRoutes.signupSuccessRouteName);
          } else if (state is SignupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: tr(AppStrings.dismiss),
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        child: CustomScaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(padding: EdgeInsets.only(left: DimensionConstants.gap8Px.w), child: CustomBackButton(onPressed: _navigateToWelcome)),
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
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomTextField(
                                      label: AppStrings.password,
                                      placeholder: AppStrings.enterYourPassword,
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      isPassword: true,
                                      validator: (value) => validatePassword(value, tr, isLogin: false),
                                      onEditingComplete: () => _confirmPasswordFocusNode.requestFocus(),
                                      onChanged: (value) {
                                        _onFieldChanged();
                                        _handlePasswordChange(value);
                                      },
                                    ),
                                    PasswordStrengthIndicator(passwordStrength: _passwordStrength, isVisible: _passwordController.text.isNotEmpty),
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
                                  validator: (value) => _validateConfirmPassword(_passwordController.text.trim(), value, tr),
                                  onEditingComplete: _handleSignUp,
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
                      builder: (context, state) {
                        final isLoading = state is SignupLoading;

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                          width: double.infinity,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              _buttonSetState = setState;
                              return ElevatedButton(
                                onPressed: _isFormValid && !isLoading ? _handleSignUp : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primary,
                                  foregroundColor: context.white,
                                  disabledBackgroundColor: context.buttonDiabled,
                                  disabledForegroundColor: context.white,
                                  padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                                  elevation: 0,
                                  side: BorderSide.none,
                                ),
                                child:
                                    isLoading
                                        ? SizedBox(
                                          height: 20.h,
                                          width: 20.w,
                                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(context.white)),
                                        )
                                        : TranslatedText(
                                          AppStrings.signUp,
                                          style: TextStyle(
                                            color: _isFormValid ? context.darkTextPrimary : context.darkTextSecondary,
                                            fontSize: DimensionConstants.font16Px.f,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              );
                            },
                          ),
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
