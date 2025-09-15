import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import '../utils/extensions/responsive_extensions.dart';
import '../utils/extensions/theme_extensions.dart';
import 'translated_text.dart';
import 'global_image.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? iconPath;
  final IconData? icon;
  final Widget? action;
  final Color? iconColor;

  const EmptyStateWidget({super.key, required this.title, required this.subtitle, this.iconPath, this.icon, this.action, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Image
            if (iconPath != null)
              GlobalImage(assetPath: iconPath!, width: 80.w, height: 80.h, color: iconColor ?? context.darkTextSecondary)
            else if (icon != null)
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(color: (iconColor ?? context.darkTextSecondary).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon!, size: 40.w, color: iconColor ?? context.darkTextSecondary),
              )
            else
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(color: context.darkTextSecondary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.schedule_outlined, size: 40.w, color: context.darkTextSecondary),
              ),

            SizedBox(height: DimensionConstants.gap24Px.h),

            // Title
            TranslatedText(
              title,
              style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: DimensionConstants.gap12Px.h),

            // Subtitle
            TranslatedText(
              subtitle,
              style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),

            if (action != null) ...[SizedBox(height: DimensionConstants.gap24Px.h), action!],
          ],
        ),
      ),
    );
  }
}
