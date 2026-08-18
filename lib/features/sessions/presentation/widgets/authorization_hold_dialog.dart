import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';

class AuthorizationHoldDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r)),
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w, vertical: DimensionConstants.gap24Px.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(dialogContext).size.height * 0.8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16181E),
                borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.customBackgroundGradient,
                  borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: dialogContext.darkTextPrimary, size: DimensionConstants.gap40Px.w),
                      SizedBox(height: DimensionConstants.gap20Px.h),
                      TranslatedText(
                        AppStrings.authorizationHoldTitle,
                        style: TextStyle(
                          color: dialogContext.darkTextPrimary,
                          fontSize: DimensionConstants.font20Px.f,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: DimensionConstants.gap12Px.h),
                      TranslatedText(
                        AppStrings.authorizationHoldMessage,
                        style: TextStyle(
                          color: dialogContext.darkTextSecondary,
                          fontSize: DimensionConstants.font14Px.f,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: DimensionConstants.gap24Px.h),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          backgroundColor: dialogContext.primary,
                          textColor: dialogContext.white,
                          borderRadius: 50.r,
                          height: 48.h,
                          padding: 0,
                          child: TranslatedText(
                            AppStrings.gotIt,
                            style: TextStyle(
                              fontSize: DimensionConstants.font16Px.f,
                              fontWeight: FontWeight.w600,
                              color: dialogContext.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
