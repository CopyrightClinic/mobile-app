import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_back_button.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_text_field.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/enumns/ui/verification_type.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with Validator {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  void Function(void Function())? _buttonSetState;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final emailValidation = validateEmail(email, tr);
    return emailValidation == null;
  }

  void _onFieldChanged() {
    _buttonSetState?.call(() {});
  }

  void _handleResetPassword(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      context.read<AuthBloc>().add(ForgotPasswordRequested(email: email));

      _emailFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: context.green, duration: const Duration(seconds: 2)));

          // Navigate to verification screen with password reset type
          context.go('/verify-code', extra: {'email': _emailController.text.trim(), 'verificationType': VerificationType.passwordReset});
        } else if (state is ForgotPasswordError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: context.red, duration: const Duration(seconds: 3)));
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
                            AppStrings.forgotPassword,
                            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font32Px.f, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: DimensionConstants.gap4Px.h),
                          TranslatedText(
                            AppStrings.forgotPasswordSubtitle,
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
                            onEditingComplete: () => _handleResetPassword(context),
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
                      final isLoading = state is ForgotPasswordLoading;

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                        width: double.infinity,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            _buttonSetState = setState;
                            return ElevatedButton(
                              onPressed: _isFormValid && !isLoading ? () => _handleResetPassword(context) : null,
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
                                        AppStrings.resetPassword,
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
