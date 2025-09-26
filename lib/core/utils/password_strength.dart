import 'package:flutter/material.dart';

enum PasswordStrengthEnum {
  weak('weak', Colors.red),
  medium('medium', Colors.orange),
  strong('strong', Colors.green),
  matched('matchPassword', Colors.green);

  final String title;
  final Color color;

  const PasswordStrengthEnum(this.title, this.color);
}

class PasswordStrengthResult {
  final PasswordStrengthEnum strength;
  final String message;

  PasswordStrengthResult({required this.strength, required this.message});
}

class PasswordStrengthHelper {
  static PasswordStrengthResult evaluatePasswordStrength(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'''[!@#\$%\^&\*\(\)_\+\-=\[\]\{\}\\\|;:,<>\./\?]'''));
    final hasSpaces = password.contains(' ');

    var characters = '''!@#\$%\^&\*\(\)_\+\-=\[\]\{\}\\\|;:,<>\./\?''';

    List<String> missingCriteria = [];

    if (password.length < 8) {
      missingCriteria.add('at-least 8 characters');
    }
    if (!hasUppercase) {
      missingCriteria.add('1 uppercase');
    }
    if (!hasLowercase) {
      missingCriteria.add('1 lowercase');
    }
    if (!hasDigits) {
      missingCriteria.add('1 digit');
    }
    if (!hasSpecialCharacters) {
      missingCriteria.add('1 special character including ${characters}');
    }
    if (hasSpaces) {
      return PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: 'Password cannot contain spaces');
    }

    // Count satisfied criteria
    int satisfiedCriteria = 5 - missingCriteria.length;

    // Determine strength and create message
    if (satisfiedCriteria >= 5) {
      return PasswordStrengthResult(strength: PasswordStrengthEnum.strong, message: 'Strong');
    } else if (satisfiedCriteria >= 3) {
      String guide = missingCriteria.isNotEmpty ? '[Password must contain: ${missingCriteria.join(", ")}]' : '';
      return PasswordStrengthResult(strength: PasswordStrengthEnum.medium, message: "Medium - $guide");
    } else {
      String guide = missingCriteria.isNotEmpty ? '[Password must contain: ${missingCriteria.join(", ")}]' : '';
      return PasswordStrengthResult(strength: PasswordStrengthEnum.weak, message: "Weak - $guide");
    }
  }
}
