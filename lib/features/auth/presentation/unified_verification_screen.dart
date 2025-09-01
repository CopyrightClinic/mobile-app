import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/utils/extensions/responsive_extensions.dart';
import '../../../core/utils/enumns/ui/verification_type.dart';
import '../../../di.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'cubit/resend_otp_cubit.dart';
import 'cubit/resend_otp_state.dart';
import 'widgets/timer_widget.dart';

class UnifiedVerificationScreen extends StatefulWidget {
  final String email;
  final VerificationType verificationType;

  const UnifiedVerificationScreen({super.key, required this.email, required this.verificationType});

  @override
  State<UnifiedVerificationScreen> createState() => _UnifiedVerificationScreenState();
}

class _UnifiedVerificationScreenState extends State<UnifiedVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthBloc _authBloc = sl<AuthBloc>();

  void _onOtpChanged(String value) {
    if (value.length == 6) {
      _verifyOtp(value);
    }
  }

  void _verifyOtp(String otp) {
    switch (widget.verificationType) {
      case VerificationType.emailVerification:
        _authBloc.add(VerifyEmailRequested(email: widget.email, otp: otp));
        break;
      case VerificationType.passwordReset:
        _authBloc.add(VerifyPasswordResetRequested(email: widget.email, otp: otp));
        break;
    }
  }

  void _resendCode(ResendOtpCubit cubit) {
    switch (widget.verificationType) {
      case VerificationType.emailVerification:
        _authBloc.add(SendEmailVerificationRequested(email: widget.email));
        break;
      case VerificationType.passwordReset:
        _authBloc.add(ForgotPasswordRequested(email: widget.email));
        break;
    }

    cubit.resetTimer();
    cubit.startResendTimer();
  }

  void _handleSuccess(AuthState state) {
    String message = '';
    String route = '';

    if (state is VerifyEmailSuccess) {
      message = state.message;
      route = AppRoutes.passwordSignupRouteName;
    } else if (state is VerifyPasswordResetSuccess) {
      message = state.message;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.green, duration: const Duration(seconds: 2)));

    if (route.isNotEmpty) {
      if (route == AppRoutes.passwordSignupRouteName) {
        context.go(route, extra: widget.email);
      } else {
        context.go(route);
      }
    }
  }

  void _handleError(AuthState state) {
    String message = '';

    if (state is VerifyEmailError) {
      message = state.message;
    } else if (state is VerifyPasswordResetError) {
      message = state.message;
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.red, duration: const Duration(seconds: 3)));
    }
  }

  void _handleResendSuccess(AuthState state) {
    String message = tr(AppStrings.codeSent);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.primary, duration: const Duration(seconds: 2)));
  }

  void _handleResendError(AuthState state) {
    String message = '';

    if (state is SendEmailVerificationError) {
      message = state.message;
    } else if (state is ForgotPasswordError) {
      message = state.message;
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.red, duration: const Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ResendOtpCubit>(),
      child: BlocListener<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (state is VerifyEmailSuccess || state is VerifyPasswordResetSuccess) {
            _handleSuccess(state);
          } else if (state is VerifyEmailError || state is VerifyPasswordResetError) {
            _handleError(state);
          } else if (state is SendEmailVerificationSuccess || state is ForgotPasswordSuccess) {
            _handleResendSuccess(state);
          } else if (state is SendEmailVerificationError || state is ForgotPasswordError) {
            _handleResendError(state);
          }
        },
        child: TimerStarter(
          child: CustomScaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Padding(padding: EdgeInsets.only(left: DimensionConstants.gap8Px.w), child: const CustomBackButton()),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: DimensionConstants.gap20Px.h),
                          _buildTitle(),
                          SizedBox(height: DimensionConstants.gap8Px.h),
                          _buildDescription(),
                          SizedBox(height: DimensionConstants.gap40Px.h),
                          _buildOtpInput(),
                          SizedBox(height: DimensionConstants.gap24Px.h),
                          _buildResendCode(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.verificationType.title,
      style: TextStyle(color: AppTheme.white, fontSize: DimensionConstants.font32Px.f, fontWeight: FontWeight.w700, fontFamily: AppTheme.fontFamily),
    );
  }

  Widget _buildDescription() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppTheme.darkTextSecondary,
          fontSize: DimensionConstants.font16Px.f,
          fontWeight: FontWeight.w400,
          fontFamily: AppTheme.fontFamily,
          height: 1.5,
        ),
        children: [
          TextSpan(text: widget.verificationType.description),
          TextSpan(text: ' (${widget.email})', style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Form(
      key: _formKey,
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        controller: _otpController,
        onChanged: _onOtpChanged,
        textStyle: TextStyle(
          color: AppTheme.white,
          fontSize: DimensionConstants.font24Px.f,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.fontFamily,
        ),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: 56.h,
          fieldWidth: 48.w,
          activeFillColor: AppTheme.filledBgDark,
          activeColor: AppTheme.filledBgDark,
          selectedColor: AppTheme.filledBgDark,
          inactiveColor: AppTheme.filledBgDark,
          selectedFillColor: AppTheme.filledBgDark,
          inactiveFillColor: AppTheme.filledBgDark,
          borderWidth: 0,
        ),
        animationType: AnimationType.fade,
        animationDuration: const Duration(milliseconds: 300),
        autoFocus: true,
        enableActiveFill: true,
        errorTextSpace: 0,
        errorAnimationController: null,
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildResendCode() {
    return BlocBuilder<ResendOtpCubit, ResendOtpState>(
      builder: (context, state) {
        final cubit = context.read<ResendOtpCubit>();
        final canResend = cubit.canResend;

        return Column(
          children: [
            if (!canResend)
              Center(
                child: Text(
                  cubit.formattedTime,
                  style: TextStyle(color: AppTheme.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600),
                ),
              ),
            SizedBox(height: DimensionConstants.gap8Px.h),
            Center(
              child: GestureDetector(
                onTap: canResend ? () => _resendCode(cubit) : null,
                child: Text(
                  widget.verificationType.resendText,
                  style: TextStyle(
                    color: canResend ? AppTheme.darkTextPrimary : AppTheme.darkTextSecondary,
                    fontSize: DimensionConstants.font12Px.f,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
