import '../../../constants/app_strings.dart';
import '../../../../config/routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';

enum VerificationType {
  emailVerification,
  passwordReset;

  String get title {
    switch (this) {
      case emailVerification:
        return tr(AppStrings.emailVerificationTitle);
      case passwordReset:
        return tr(AppStrings.passwordResetTitle);
    }
  }

  String get description {
    switch (this) {
      case emailVerification:
        return tr(AppStrings.emailVerificationDescription);
      case passwordReset:
        return tr(AppStrings.passwordResetDescription);
    }
  }

  String get buttonText {
    switch (this) {
      case emailVerification:
        return tr(AppStrings.verifyEmailButton);
      case passwordReset:
        return tr(AppStrings.verifyCodeButton);
    }
  }

  String get resendText {
    return tr(AppStrings.resendCodeButton);
  }

  String get successRoute {
    switch (this) {
      case emailVerification:
        return AppRoutes.passwordSignupRouteName;
      case passwordReset:
        return AppRoutes.resetPasswordRouteName;
    }
  }
}
