import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
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
      margin: EdgeInsets.only(top: DimensionConstants.gap8Px.h),
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap12Px.w, vertical: DimensionConstants.gap8Px.h),
      decoration: BoxDecoration(
        color: passwordStrength!.strength.color.withAlpha(10),
        borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.h),
        border: Border.all(color: passwordStrength!.strength.color.withAlpha(30), width: 1.0),
      ),
      child: Row(
        children: [
          _getStrengthIcon(passwordStrength!.strength),
          SizedBox(width: DimensionConstants.gap8Px.w),
          Expanded(
            child: Text(
              passwordStrength!.message,
              style: TextStyle(color: passwordStrength!.strength.color, fontSize: DimensionConstants.font12Px.f, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStrengthIcon(PasswordStrengthEnum strength) {
    switch (strength) {
      case PasswordStrengthEnum.weak:
        return Icon(Icons.error_outline, color: strength.color, size: DimensionConstants.icon16Px.h);
      case PasswordStrengthEnum.medium:
        return Icon(Icons.warning_amber_outlined, color: strength.color, size: DimensionConstants.icon16Px.h);
      case PasswordStrengthEnum.strong:
        return Icon(Icons.check_circle_outline, color: strength.color, size: DimensionConstants.icon16Px.h);
      case PasswordStrengthEnum.matched:
        return Icon(Icons.verified_outlined, color: strength.color, size: DimensionConstants.icon16Px.h);
    }
  }
}
