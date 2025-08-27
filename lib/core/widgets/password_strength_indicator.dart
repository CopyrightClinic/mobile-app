import 'package:flutter/material.dart';
import '../utils/password_strength.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrengthResult? passwordStrength;
  final bool isVisible;

  const PasswordStrengthIndicator({super.key, this.passwordStrength, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible || passwordStrength == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: passwordStrength!.strength.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: passwordStrength!.strength.color.withOpacity(0.3), width: 1.0),
      ),
      child: Row(
        children: [
          _getStrengthIcon(passwordStrength!.strength),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              passwordStrength!.message,
              style: TextStyle(color: passwordStrength!.strength.color, fontSize: 12.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStrengthIcon(PasswordStrengthEnum strength) {
    switch (strength) {
      case PasswordStrengthEnum.weak:
        return Icon(Icons.error_outline, color: strength.color, size: 16.0);
      case PasswordStrengthEnum.medium:
        return Icon(Icons.warning_amber_outlined, color: strength.color, size: 16.0);
      case PasswordStrengthEnum.strong:
        return Icon(Icons.check_circle_outline, color: strength.color, size: 16.0);
      case PasswordStrengthEnum.matched:
        return Icon(Icons.verified_outlined, color: strength.color, size: 16.0);
    }
  }
}
