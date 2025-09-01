import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions/responsive_extensions.dart';
import '../../../core/utils/extensions/theme_extensions.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/translated_text.dart';
import '../../../core/utils/mixin/validator.dart';
import '../../../config/routes/app_routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

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

    final emailValidation = validateEmail(email, tr);
    final passwordValidation = validatePassword(password, tr, isLogin: true);

    return emailValidation == null && passwordValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      context.read<AuthBloc>().add(LoginRequested(email: email, password: password));

      _passwordFocusNode.unfocus();
    }
  }

  void _handleForgotPassword() {
    context.go(AppRoutes.forgotPasswordRouteName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green, duration: const Duration(seconds: 3)));
        } else if (state is LoginError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
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
                            AppStrings.login,
                            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font32Px.f, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: DimensionConstants.gap4Px.h),
                          TranslatedText(
                            AppStrings.welcomeBackMessage,
                            style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: DimensionConstants.gap40Px.h),
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
                          SizedBox(height: DimensionConstants.gap24Px.h),
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
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is LoginLoading;

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                        width: double.infinity,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            _buttonSetState = setState;
                            return ElevatedButton(
                              onPressed: _isFormValid && !isLoading ? _handleLogin : null,
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
                                        AppStrings.login,
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
    );
  }
}
