import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/utils/logger/logger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions/responsive_extensions.dart';
import '../../../core/utils/extensions/theme_extensions.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/translated_text.dart';
import '../../../core/utils/mixin/validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordController = TextEditingController();
  final _confirmPasswordFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    Log.d('SignUpScreen', 'email: $email, password: $password, confirmPassword: $confirmPassword');

    final emailValidation = validateEmail(email, tr);
    final passwordValidation = validatePassword(password, tr, isLogin: false);
    final confirmPasswordValidation = _validateConfirmPassword(password, confirmPassword, tr);

    return emailValidation == null && passwordValidation == null && confirmPasswordValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      _confirmPasswordFocusNode.unfocus();
      Log.d('SignUpScreen', 'Sign up form validated successfully');
    }
  }

  void _handleForgotPassword() {}

  String? _validateConfirmPassword(String? password, String? confirmPassword, String Function(String) tr) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return tr(AppStrings.confirmPasswordIsRequired);
    } else if (password != confirmPassword) {
      return tr(AppStrings.passwordsDoNotMatch);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
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
                          style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: DimensionConstants.gap20Px.h),
                        CustomTextField(
                          label: AppStrings.email,
                          placeholder: AppStrings.enterYourEmail,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => validateEmail(value, tr),
                          onEditingComplete: () => _passwordFocusNode.requestFocus(),
                          onChanged: (value) {
                            _onFieldChanged();
                          },
                        ),
                        SizedBox(height: DimensionConstants.gap20Px.h),
                        CustomTextField(
                          label: AppStrings.password,
                          placeholder: AppStrings.enterYourPassword,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          isPassword: true,
                          validator: (value) => validatePassword(value, tr, isLogin: false),
                          onEditingComplete: _handleSignUp,
                          onChanged: (value) {
                            _onFieldChanged();
                          },
                        ),
                        SizedBox(height: DimensionConstants.gap20Px.h),
                        CustomTextField(
                          label: AppStrings.confirmPassword,
                          placeholder: AppStrings.confirmPassword,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          isPassword: true,
                          validator: (value) => _validateConfirmPassword(_passwordController.text.trim(), value, tr),
                          onChanged: (value) {
                            _onFieldChanged();
                          },
                        ),
                        SizedBox(height: DimensionConstants.gap16Px.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: TranslatedText(
                              AppStrings.forgotPassword,
                              style: TextStyle(color: context.primaryColor, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      _buttonSetState = setState;
                      return ElevatedButton(
                        onPressed: _isFormValid ? _handleSignUp : null,
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
                        child: TranslatedText(
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
                ),
                SizedBox(height: DimensionConstants.gap32Px.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
