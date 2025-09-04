import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/verify_password_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final VerifyPasswordResetOtpUseCase verifyPasswordResetOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final CompleteProfileUseCase completeProfileUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.verifyEmailUseCase,
    required this.sendEmailVerificationUseCase,
    required this.verifyPasswordResetOtpUseCase,
    required this.resetPasswordUseCase,
    required this.completeProfileUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyPasswordResetRequested>(_onVerifyPasswordResetRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<CompleteProfileRequested>(_onCompleteProfileRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(LoginLoading());

    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold(
      (failure) => emit(LoginError(failure.message ?? tr(AppStrings.loginFailed))),
      (authResult) => emit(LoginSuccess(authResult.user, authResult.message)),
    );
  }

  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(SignupLoading());

    final result = await signupUseCase(SignupParams(email: event.email, password: event.password, confirmPassword: event.confirmPassword));

    result.fold(
      (failure) => emit(SignupError(failure.message ?? tr(AppStrings.signupFailed))),
      (authResult) => emit(SignupSuccess(authResult.user, authResult.message)),
    );
  }

  Future<void> _onVerifyEmailRequested(VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(VerifyEmailLoading());

    final result = await verifyEmailUseCase(VerifyEmailParams(email: event.email, otp: event.otp));

    result.fold(
      (failure) => emit(VerifyEmailError(failure.message ?? tr(AppStrings.emailVerificationFailed))),
      (emailResult) => emit(VerifyEmailSuccess(emailResult.message)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onSendEmailVerificationRequested(SendEmailVerificationRequested event, Emitter<AuthState> emit) async {
    emit(SendEmailVerificationLoading());

    final result = await sendEmailVerificationUseCase(SendEmailVerificationParams(email: event.email));

    result.fold(
      (failure) => emit(SendEmailVerificationError(failure.message ?? tr(AppStrings.failedToSendVerificationEmail))),
      (message) => emit(SendEmailVerificationSuccess(message)),
    );
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordLoading());

    final result = await authRepository.forgotPassword(event.email);

    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message ?? tr(AppStrings.passwordResetFailed))),
      (message) => emit(ForgotPasswordSuccess(message)),
    );
  }

  Future<void> _onVerifyPasswordResetRequested(VerifyPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(VerifyPasswordResetLoading());

    final result = await verifyPasswordResetOtpUseCase(VerifyPasswordResetOtpParams(email: event.email, otp: event.otp));

    result.fold(
      (failure) => emit(VerifyPasswordResetError(failure.message ?? tr(AppStrings.passwordResetFailed))),
      (message) => emit(VerifyPasswordResetSuccess(message)),
    );
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(ResetPasswordLoading());

    final result = await resetPasswordUseCase(
      ResetPasswordParams(email: event.email, otp: event.otp, newPassword: event.newPassword, confirmPassword: event.confirmPassword),
    );

    result.fold(
      (failure) => emit(ResetPasswordError(failure.message ?? tr(AppStrings.passwordResetFailed))),
      (message) => emit(ResetPasswordSuccess(message)),
    );
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onCompleteProfileRequested(CompleteProfileRequested event, Emitter<AuthState> emit) async {
    emit(CompleteProfileLoading());
    final result = await completeProfileUseCase(CompleteProfileParams(name: event.name, phoneNumber: event.phoneNumber, address: event.address));
    result.fold(
      (failure) => emit(CompleteProfileError(failure.message ?? tr(AppStrings.profileUpdateFailed))),
      (message) => emit(CompleteProfileSuccess(message)),
    );
  }
}
