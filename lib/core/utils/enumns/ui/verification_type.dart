enum VerificationType {
  emailVerification,
  passwordReset;

  String get title {
    switch (this) {
      case emailVerification:
        return 'Email Verification';
      case passwordReset:
        return 'Password Reset';
    }
  }

  String get description {
    switch (this) {
      case emailVerification:
        return 'We have sent a verification code to your email address. Please enter the code below to verify your account.';
      case passwordReset:
        return 'We have sent a reset code to your email address. Please enter the code below to reset your password.';
    }
  }

  String get buttonText {
    switch (this) {
      case emailVerification:
        return 'Verify Email';
      case passwordReset:
        return 'Verify Code';
    }
  }

  String get resendText {
    switch (this) {
      case emailVerification:
        return 'Verification code';
      case passwordReset:
        return 'Reset code';
    }
  }

  String get successRoute {
    switch (this) {
      case emailVerification:
        return '/password-signup';
      case passwordReset:
        return '/reset-password';
    }
  }
}
