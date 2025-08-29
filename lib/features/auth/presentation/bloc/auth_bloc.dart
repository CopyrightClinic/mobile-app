import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final AuthRepository authRepository;

  AuthBloc({required this.loginUseCase, required this.signupUseCase, required this.verifyEmailUseCase, required this.authRepository})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyPasswordResetRequested>(_onVerifyPasswordResetRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(LoginLoading());

    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold(
      (failure) => emit(LoginError(failure.message ?? 'Login failed')),
      (authResult) => emit(LoginSuccess(authResult.user, authResult.message)),
    );
  }

  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(SignupLoading());

    final result = await signupUseCase(SignupParams(email: event.email, password: event.password, confirmPassword: event.confirmPassword));

    result.fold(
      (failure) => emit(SignupError(failure.message ?? 'Signup failed')),
      (authResult) => emit(SignupSuccess(authResult.user, authResult.message)),
    );
  }

  Future<void> _onVerifyEmailRequested(VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(VerifyEmailLoading());

    final result = await verifyEmailUseCase(VerifyEmailParams(email: event.email, otp: event.otp));

    result.fold(
      (failure) => emit(VerifyEmailError(failure.message ?? 'Email verification failed')),
      (emailResult) => emit(VerifyEmailSuccess(emailResult.message)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordLoading());

    // TODO: Implement forgot password use case when backend support is added
    // For now, simulate success
    await Future.delayed(const Duration(seconds: 1));
    emit(ForgotPasswordSuccess('Reset code sent to ${event.email}'));

    // Example implementation when use case is ready:
    // final result = await forgotPasswordUseCase(ForgotPasswordParams(email: event.email));
    // result.fold(
    //   (failure) => emit(ForgotPasswordError(failure.message ?? 'Failed to send reset code')),
    //   (result) => emit(ForgotPasswordSuccess(result.message)),
    // );
  }

  Future<void> _onVerifyPasswordResetRequested(VerifyPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(VerifyPasswordResetLoading());

    // TODO: Implement verify password reset use case when backend support is added
    // For now, simulate success
    await Future.delayed(const Duration(seconds: 1));
    emit(VerifyPasswordResetSuccess('Password reset code verified successfully'));

    // Example implementation when use case is ready:
    // final result = await verifyPasswordResetUseCase(VerifyPasswordResetParams(email: event.email, otp: event.otp));
    // result.fold(
    //   (failure) => emit(VerifyPasswordResetError(failure.message ?? 'Invalid reset code')),
    //   (result) => emit(VerifyPasswordResetSuccess(result.message)),
    // );
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
