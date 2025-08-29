import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;

  const SignupRequested({required this.email, required this.password, required this.confirmPassword});

  @override
  List<Object?> get props => [email, password, confirmPassword];
}

class VerifyEmailRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyEmailRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyPasswordResetRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyPasswordResetRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class SendEmailVerificationRequested extends AuthEvent {
  final String email;

  const SendEmailVerificationRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
