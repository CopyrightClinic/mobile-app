import '../../constants/app_strings.dart';

mixin Validator {
  String? validateEmail(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.emailIsRequired);
    } else if (!RegExp(
      "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)\$",
    ).hasMatch(value)) {
      return tr(AppStrings.pleaseEnterAValidEmail);
    }
    return null;
  }

  String? validatePassword(String? value, String Function(String) tr, {bool isLogin = false}) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.passwordIsRequired);
    }

    if (isLogin) {
      return null;
    }

    if (value.length < 8) {
      return tr(AppStrings.passwordMustBeAtLeastXCharacters).replaceAll('{X}', '8');
    }

    if (value.contains(' ')) {
      return tr(AppStrings.passwordNoSpaces);
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least 1 lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 digit';
    }

    if (!value.contains(RegExp(r'''[!@#\$%\^&\*\(\)_\+\-=\[\]\{\}\\\|;:,<>\./\?]'''))) {
      return 'Password must contain at least 1 special character (!@#\$%^&*()_+-=[]{}|\\;:,<>./?)';
    }

    return null;
  }

  String? validateName(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.nameIsRequired);
    } else if (value.length < 3) {
      return tr(AppStrings.nameMustBeAtLeastXCharacters).replaceAll('{X}', '3');
    }
    return null;
  }

  String? validatePhone(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.phoneIsRequired);
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return tr(AppStrings.pleaseEnterAValidPhoneNumber);
    }
    return null;
  }
}
