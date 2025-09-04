import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/dimensions.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr(),
          style: TextStyle(
            fontSize: DimensionConstants.font16Px,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        SizedBox(height: DimensionConstants.gap8Px),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.filledBgDark : AppTheme.white,
            borderRadius: BorderRadius.circular(DimensionConstants.radius12Px),
            border: Border.all(color: isDark ? AppTheme.gradientBgDark : AppTheme.border, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            obscureText: obscureText,
            enabled: enabled,
            style: TextStyle(
              fontSize: DimensionConstants.font16Px,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontFamily: AppTheme.fontFamily,
            ),
            decoration: InputDecoration(
              hintText: hint.tr(),
              hintStyle: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.placeholder,
                fontSize: DimensionConstants.font16Px,
                fontFamily: AppTheme.fontFamily,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px, vertical: DimensionConstants.gap16Px),
            ),
          ),
        ),
      ],
    );
  }
}
