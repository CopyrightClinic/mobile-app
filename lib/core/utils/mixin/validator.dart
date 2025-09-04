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
      return tr(AppStrings.passwordMustContainUppercase);
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return tr(AppStrings.passwordMustContainLowercase);
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return tr(AppStrings.passwordMustContainDigit);
    }

    if (!value.contains(RegExp(r'''[!@#\$%\^&\*\(\)_\+\-=\[\]\{\}\\\|;:,<>\./\?]'''))) {
      return tr(AppStrings.passwordMustContainSpecialChar);
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

  String? validateFullName(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.fullNameIsRequired);
    } else if (value.trim().length < 2) {
      return tr(AppStrings.fullNameMustBeAtLeast2Characters);
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return tr(AppStrings.fullNameCanOnlyContainLetters);
    }
    return null;
  }

  String? validatePhoneNumber(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.phoneNumberIsRequired);
    } else if (value.length < 10) {
      return tr(AppStrings.phoneNumberMustBeAtLeast10Digits);
    } else if (!RegExp(r'^[+]?[0-9\s\-\(\)]+$').hasMatch(value)) {
      return tr(AppStrings.pleaseEnterAValidPhoneNumber);
    }
    return null;
  }

  String? validateAddress(String? value, String Function(String) tr) {
    if (value == null || value.isEmpty) {
      return tr(AppStrings.addressIsRequired);
    } else if (value.trim().length < 5) {
      return tr(AppStrings.addressMustBeAtLeast5Characters);
    }
    return null;
  }
}
