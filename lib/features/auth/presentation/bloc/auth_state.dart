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
