abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;

  const SignupRequested({required this.email, required this.password, required this.confirmPassword});
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
