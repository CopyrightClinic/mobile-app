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
    if (isLogin) {
      if (value == null || value.isEmpty) {
        return tr(AppStrings.passwordIsRequired);
      }
    } else {
      if (value == null || value.isEmpty) {
        return tr(AppStrings.passwordIsRequired);
      } else if (value.length < 6) {
        return tr(AppStrings.passwordMustBeAtLeastXCharacters).replaceAll('{X}', '6');
      }
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
