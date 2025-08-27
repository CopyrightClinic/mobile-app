import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/widgets/global_image.dart';
import '../../../core/widgets/translated_text.dart';

class SignupSuccessScreen extends StatelessWidget {
  const SignupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap15Px.w),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: DimensionConstants.gap20Px.h),
              GlobalImage(assetPath: ImageConstants.logo, width: 105.8.w),
              SizedBox(height: DimensionConstants.gap16Px.h),
              TranslatedText(
                AppStrings.appName,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: DimensionConstants.gap72Px.h),
              GlobalImage(assetPath: ImageConstants.signupSuccess, width: 190.w),
              SizedBox(height: DimensionConstants.gap64Px.h),
              TranslatedText(
                AppStrings.congratulations,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
              ),
              TranslatedText(
                AppStrings.yourAccountHasBeenCreated,
                style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: context.white,
                    disabledBackgroundColor: context.buttonDiabled,
                    disabledForegroundColor: context.white,
                    padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                    elevation: 0,
                    side: BorderSide.none,
                  ),
                  child: TranslatedText(
                    AppStrings.setupProfile,
                    style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
