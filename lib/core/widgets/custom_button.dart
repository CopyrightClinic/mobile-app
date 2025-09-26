import 'dart:developer';

import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.disabledBackgroundColor,
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

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
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
        disabledBackgroundColor: disabledBackgroundColor,
        padding: EdgeInsets.symmetric(vertical: padding.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 0)),
      ),
      child: isLoading ? const CircularProgressIndicator() : child,
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.text, required this.onPressed, this.isLoading = false, this.isEnabled = true});

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: context.white,
          disabledBackgroundColor: context.buttonDisabled,
          disabledForegroundColor: context.white,
          padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
          elevation: 0,
          side: BorderSide.none,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(context.white)),
                )
                : TranslatedText(
                  text,
                  style: TextStyle(
                    color: isEnabled ? context.darkTextPrimary : context.darkTextSecondary,
                    fontSize: DimensionConstants.font16Px.f,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
