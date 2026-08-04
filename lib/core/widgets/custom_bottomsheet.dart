import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../utils/extensions/responsive_extensions.dart';
import '../utils/extensions/theme_extensions.dart';
import '../services/bottom_sheet_service.dart';
import 'global_image.dart';
import 'translated_text.dart';
import 'custom_button.dart';

class CustomBottomSheet extends StatelessWidget {
  final String? iconPath;
  final Widget? customIcon;
  final String? title;
  final String? subtitle;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final Color? primaryTextColor;
  final Color? secondaryTextColor;
  final Widget? content;
  final bool isPrimaryLoading;
  final bool isPrimaryEnabled;

  const CustomBottomSheet({
    super.key,
    this.iconPath,
    this.customIcon,
    this.title,
    this.subtitle,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.content,
    this.isPrimaryLoading = false,
    this.isPrimaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF16181E),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.customBackgroundGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DimensionConstants.radius20Px.r),
                  topRight: Radius.circular(DimensionConstants.radius20Px.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: DimensionConstants.gap12Px.h),
                    decoration: BoxDecoration(
                      color: context.white,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  if (customIcon != null || iconPath != null) ...[
                    SizedBox(height: DimensionConstants.gap32Px.h),
                    if (customIcon != null)
                      customIcon!
                    else if (iconPath != null)
                      GlobalImage(
                        assetPath: iconPath!,
                        width: DimensionConstants.gap48Px.w,
                        height: DimensionConstants.gap48Px.h,
                        loadingSize: DimensionConstants.gap40Px.w,
                      ),
                  ],

                  if (title != null || subtitle != null) ...[
                    SizedBox(height: DimensionConstants.gap24Px.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DimensionConstants.gap24Px.w,
                      ),
                      child: Column(
                        children: [
                          if (title != null)
                            TranslatedText(
                              title!,
                              style: TextStyle(
                                color: context.darkTextPrimary,
                                fontSize: DimensionConstants.font20Px.f,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),

                          if (subtitle != null) ...[
                            SizedBox(height: DimensionConstants.gap12Px.h),
                            TranslatedText(
                              subtitle!,
                              style: TextStyle(
                                color: context.darkTextSecondary,
                                fontSize: DimensionConstants.font14Px.f,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  if (content != null) ...[
                    SizedBox(height: DimensionConstants.gap20Px.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DimensionConstants.gap24Px.w,
                      ),
                      child: content!,
                    ),
                  ],

                  SizedBox(height: DimensionConstants.gap32Px.h),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: DimensionConstants.gap24Px.w,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed:
                                isPrimaryLoading ? null : onSecondaryPressed,
                            backgroundColor:
                                secondaryButtonColor ?? context.buttonSecondary,
                            textColor:
                                secondaryTextColor ?? context.darkTextPrimary,
                            borderColor: context.buttonSecondary,
                            borderWidth: 1,
                            borderRadius: 50.r,
                            height: 48.h,
                            padding: 0,
                            child: TranslatedText(
                              secondaryButtonText,
                              style: TextStyle(
                                fontSize: DimensionConstants.font16Px.f,
                                fontWeight: FontWeight.w600,
                                color:
                                    secondaryTextColor ??
                                    context.darkTextPrimary,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: DimensionConstants.gap12Px.w),

                        Expanded(
                          child: CustomButton(
                            onPressed:
                                isPrimaryLoading || !isPrimaryEnabled
                                    ? null
                                    : onPrimaryPressed,
                            isLoading: isPrimaryLoading,
                            backgroundColor: primaryButtonColor ?? context.red,
                            textColor: primaryTextColor ?? Colors.white,
                            borderRadius: 50.r,
                            height: 48.h,
                            padding: 0,
                            child: TranslatedText(
                              primaryButtonText,
                              style: TextStyle(
                                fontSize: DimensionConstants.font16Px.f,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor ?? Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: DimensionConstants.gap24Px.h),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? iconPath,
    Widget? customIcon,
    String? title,
    String? subtitle,
    required String primaryButtonText,
    required String secondaryButtonText,
    required VoidCallback onPrimaryPressed,
    required VoidCallback onSecondaryPressed,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Widget? content,
    bool isPrimaryLoading = false,
    bool isPrimaryEnabled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return BottomSheetService.show<T>(
      builder:
          (context) => CustomBottomSheet(
            iconPath: iconPath,
            customIcon: customIcon,
            title: title,
            subtitle: subtitle,
            primaryButtonText: primaryButtonText,
            secondaryButtonText: secondaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
            onSecondaryPressed: onSecondaryPressed,
            primaryButtonColor: primaryButtonColor,
            secondaryButtonColor: secondaryButtonColor,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
            content: content,
            isPrimaryLoading: isPrimaryLoading,
            isPrimaryEnabled: isPrimaryEnabled,
          ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }
}
