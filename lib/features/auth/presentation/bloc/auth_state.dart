import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final UserEntity user;
  final String message; // API message

  const LoginSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class LoginError extends AuthState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

class SignupLoading extends AuthState {}

class SignupSuccess extends AuthState {
  final UserEntity user;
  final String message; // API message

  const SignupSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class SignupError extends AuthState {
  final String message;

  const SignupError(this.message);

  @override
  List<Object?> get props => [message];
}

class VerifyEmailLoading extends AuthState {}

class VerifyEmailSuccess extends AuthState {
  final String message;

  const VerifyEmailSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VerifyEmailError extends AuthState {
  final String message;

  const VerifyEmailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordLoading extends AuthState {}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  const ForgotPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends AuthState {
  final String message;

  const ForgotPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}

class VerifyPasswordResetLoading extends AuthState {}

class VerifyPasswordResetSuccess extends AuthState {
  final String message;

  const VerifyPasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VerifyPasswordResetError extends AuthState {
  final String message;

  const VerifyPasswordResetError(this.message);

  @override
  List<Object?> get props => [message];
}

class SendEmailVerificationLoading extends AuthState {}

class SendEmailVerificationSuccess extends AuthState {
  final String message;

  const SendEmailVerificationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SendEmailVerificationError extends AuthState {
  final String message;

  const SendEmailVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetPasswordLoading extends AuthState {}

class ResetPasswordSuccess extends AuthState {
  final String message;

  const ResetPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetPasswordError extends AuthState {
  final String message;

  const ResetPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompleteProfileLoading extends AuthState {}

class CompleteProfileSuccess extends AuthState {
  final String message;

  const CompleteProfileSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CompleteProfileError extends AuthState {
  final String message;

  const CompleteProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ResendEmailVerificationLoading extends AuthState {}

class ResendEmailVerificationSuccess extends AuthState {
  final String message;

  const ResendEmailVerificationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResendEmailVerificationError extends AuthState {
  final String message;

  const ResendEmailVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class ResendForgotPasswordLoading extends AuthState {}

class ResendForgotPasswordSuccess extends AuthState {
  final String message;

  const ResendForgotPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResendForgotPasswordError extends AuthState {
  final String message;

  const ResendForgotPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
