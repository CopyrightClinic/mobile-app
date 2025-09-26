import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../config/routes/app_routes.dart';

class HaroldSignupScreen extends StatelessWidget {
  const HaroldSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w), leading: const CustomBackButton()),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(right: DimensionConstants.gap26Px.w),
                child: GlobalImage(assetPath: ImageConstants.haroldSignup, width: 200.w, height: 350.h, fit: BoxFit.contain),
              ),

              SizedBox(height: DimensionConstants.gap26Px.h),

              TranslatedText(
                AppStrings.haroldAiHasResponseForYou,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DimensionConstants.gap8Px.h),

              TranslatedText(
                AppStrings.pleaseSignUpOrLogInToViewIt,
                style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              AuthButton(text: AppStrings.signUp, onPressed: () => context.push(AppRoutes.signupRouteName), isLoading: false, isEnabled: true),

              GestureDetector(
                onTap: () => context.push(AppRoutes.loginRouteName),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TranslatedText(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: DimensionConstants.font14Px),
                    ),
                    SizedBox(width: 4.w),
                    TranslatedText(
                      AppStrings.login,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: DimensionConstants.font14Px,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DimensionConstants.gap10Px.h),
            ],
          ),
        ),
      ),
    );
  }
}
