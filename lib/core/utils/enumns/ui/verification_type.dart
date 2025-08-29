enum VerificationType { emailVerification, passwordReset }

extension VerificationTypeExtension on VerificationType {
  String get title {
    switch (this) {
      case VerificationType.emailVerification:
        return 'Verification Code';
      case VerificationType.passwordReset:
        return 'Verification Code';
    }
  }

  String get description {
    switch (this) {
      case VerificationType.emailVerification:
        return 'Enter the verification code that we have sent to your email';
      case VerificationType.passwordReset:
        return 'Enter the verification code that we have sent to your email';
    }
  }

  String get buttonText {
    switch (this) {
      case VerificationType.emailVerification:
        return 'Verify';
      case VerificationType.passwordReset:
        return 'Verify Code';
    }
  }

  String get resendText {
    switch (this) {
      case VerificationType.emailVerification:
        return 'Resend Code';
      case VerificationType.passwordReset:
        return 'Resend Code';
    }
  }

  String get successRoute {
    switch (this) {
      case VerificationType.emailVerification:
        return '/signup-success';
      case VerificationType.passwordReset:
        return '/reset-password'; // TODO: Add reset password route
    }
  }
}
