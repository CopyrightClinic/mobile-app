import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/config/routes/app_routes.dart';
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

import '../../../core/utils/enumns/ui/verification_type.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final emailValidation = validateEmail(email, tr);
    return emailValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleVerifyEmail() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      context.read<AuthBloc>().add(SendEmailVerificationRequested(email: email));

      _emailFocusNode.unfocus();
    }
  }

  /// Formats API success messages for better display
  String _formatApiMessage(String message) {
    // Handle common API messages and make them more user-friendly
    if (message.toLowerCase().contains('successful')) {
      return '🎉 $message';
    } else if (message.toLowerCase().contains('welcome')) {
      return '👋 $message';
    } else if (message.toLowerCase().contains('created')) {
      return '✅ $message';
    }
    return message;
  }

  /// Formats error messages for better display
  String _formatErrorMessage(String message) {
    // Handle common error patterns and make them more user-friendly
    if (message.toLowerCase().contains('invalid')) {
      return '❌ $message';
    } else if (message.toLowerCase().contains('required')) {
      return '⚠️ $message';
    } else if (message.toLowerCase().contains('already exists')) {
      return '🚫 $message';
    } else if (message.toLowerCase().contains('network') || message.toLowerCase().contains('connection')) {
      return '🌐 $message';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SendEmailVerificationSuccess) {
          final message = _formatApiMessage(state.message);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 3)));
          context.push(
            AppRoutes.verifyCodeRouteName,
            extra: {'email': _emailController.text.trim(), 'verificationType': VerificationType.emailVerification},
          );
        } else if (state is SendEmailVerificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_formatErrorMessage(state.message)),
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
                            AppStrings.createAccount,
                            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: DimensionConstants.gap4Px.h),
                          TranslatedText(
                            AppStrings.enterEmailForVerification,
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
                            onEditingComplete: _handleVerifyEmail,
                            onChanged: (value) {
                              _onFieldChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is SendEmailVerificationLoading;

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                        width: double.infinity,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            _buttonSetState = setState;
                            return ElevatedButton(
                              onPressed: _isFormValid && !isLoading ? _handleVerifyEmail : null,
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
                                        AppStrings.verifyEmail,
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

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }
}
