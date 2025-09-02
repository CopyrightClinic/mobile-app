import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_routes.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../di.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'cubit/resend_otp_cubit.dart';
import 'cubit/resend_otp_state.dart';
import 'widgets/timer_widget.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ResendOtpCubit>(),
      child: BlocListener<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (state is VerifyEmailSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.green, duration: const Duration(seconds: 2)));
            context.go(AppRoutes.signupSuccessRouteName);
          } else if (state is VerifyEmailError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.red, duration: const Duration(seconds: 3)));
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
                  Padding(padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w), child: _buildVerifyButton()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onOtpChanged(String value) {
    if (value.length == 6) {
      _verifyOtp(value);
    }
  }

  void _verifyOtp(String otp) {
    _authBloc.add(VerifyEmailRequested(email: widget.email, otp: otp));
  }

  void _resendCode(ResendOtpCubit cubit) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code resent!'), backgroundColor: AppTheme.primary, duration: Duration(seconds: 2)));

    cubit.resetTimer();
    cubit.startResendTimer();
  }

  Widget _buildTitle() {
    return Text(
      'Verification Code',
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
          const TextSpan(text: 'Enter the verification code that we have sent to your email '),
          TextSpan(text: '(${widget.email})', style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w500)),
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
        onCompleted: _verifyOtp,
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
        final cubit = sl<ResendOtpCubit>();
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
                  'Resend Code',
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

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isOtpComplete = _otpController.text.length == 6;
        final isLoading = state is VerifyEmailLoading;
        final isEnabled = isOtpComplete && !isLoading;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
          child: ElevatedButton(
            onPressed: isEnabled ? () => _verifyOtp(_otpController.text) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? AppTheme.primary : AppTheme.buttonDiabled,
              foregroundColor: AppTheme.white,
              disabledBackgroundColor: AppTheme.buttonDiabled,
              disabledForegroundColor: AppTheme.white,
              padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
              elevation: 0,
              side: BorderSide.none,
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white)),
                    )
                    : Text(
                      'Verify',
                      style: TextStyle(
                        color: isEnabled ? AppTheme.white : AppTheme.darkTextSecondary,
                        fontSize: DimensionConstants.font16Px.f,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _authBloc.close();
    super.dispose();
  }
}
