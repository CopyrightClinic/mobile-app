import 'package:copyright_clinic_flutter/core/utils/extensions/responsive_extensions.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.height,
    this.width,
    this.padding = 16,
    this.margin,
    this.fontSize,
    this.isLoading = false,
    this.isDisabled = false,
  });
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double padding;
  final double? margin;
  final double? fontSize;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: padding.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 0)),
      ),
      child: isLoading ? const CircularProgressIndicator() : child,
    );
  }
}
