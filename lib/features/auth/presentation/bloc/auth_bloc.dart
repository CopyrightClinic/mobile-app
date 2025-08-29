import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.verifyEmailUseCase,
    required this.sendEmailVerificationUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyPasswordResetRequested>(_onVerifyPasswordResetRequested);
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
    await Future.delayed(const Duration(seconds: 1));
    emit(ForgotPasswordSuccess(tr(AppStrings.resetCodeSentTo, namedArgs: {'email': event.email})));
  }

  Future<void> _onVerifyPasswordResetRequested(VerifyPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(VerifyPasswordResetLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(VerifyPasswordResetSuccess(tr(AppStrings.passwordResetCodeVerified)));
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
}
