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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    Log.d('LoginScreen', 'email: $email, password: $password');

    return email.isNotEmpty && password.isNotEmpty;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _passwordFocusNode.unfocus();
    }
  }

  void _handleForgotPassword() {}

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(padding: EdgeInsets.only(left: 8.w), child: const CustomBackButton()),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                        SizedBox(height: 20.h),
                        TranslatedText(
                          AppStrings.login,
                          style: TextStyle(color: context.darkTextPrimary, fontSize: 32.f, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4.h),
                        TranslatedText(
                          AppStrings.welcomeBackMessage,
                          style: TextStyle(color: context.darkTextSecondary, fontSize: 16.f, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: 40.h),
                        CustomTextField(
                          label: AppStrings.email,
                          placeholder: AppStrings.enterYourEmail,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          onEditingComplete: () => _passwordFocusNode.requestFocus(),
                          onChanged: (value) {
                            _onFieldChanged();
                          },
                        ),
                        SizedBox(height: 24.h),
                        CustomTextField(
                          label: AppStrings.password,
                          placeholder: AppStrings.enterYourPassword,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          isPassword: true,
                          validator: (value) => validatePassword(value, tr, isLogin: true),
                          onEditingComplete: _handleLogin,
                          onChanged: (value) {
                            _onFieldChanged();
                          },
                        ),
                        SizedBox(height: 16.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: TranslatedText(
                              AppStrings.forgotPassword,
                              style: TextStyle(color: context.primaryColor, fontSize: 14.f, fontWeight: FontWeight.w500),
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
                        onPressed: _isFormValid ? _handleLogin : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: context.white,
                          disabledBackgroundColor: context.buttonDiabled,
                          disabledForegroundColor: context.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        child: TranslatedText(
                          AppStrings.login,
                          style: TextStyle(
                            color: _isFormValid ? context.darkTextPrimary : context.darkTextSecondary,
                            fontSize: 16.f,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
