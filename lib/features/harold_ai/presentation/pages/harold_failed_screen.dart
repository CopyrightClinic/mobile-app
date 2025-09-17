import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../config/routes/app_routes.dart';

class HaroldFailedScreen extends StatelessWidget {
  final bool fromAuthFlow;

  const HaroldFailedScreen({super.key, this.fromAuthFlow = false});

  void _handleBackPress(BuildContext context) {
    if (fromAuthFlow) {
      // User came from welcome -> harold -> signup/login -> result
      // Navigate to home screen to prevent going back to welcome
      context.go(AppRoutes.homeRouteName);
    } else {
      // User was already authenticated and came from home -> harold -> result
      // Normal back navigation (pop to previous screen)
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: CustomBackButton(onPressed: () => _handleBackPress(context)),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
          width: double.infinity,
          child: Column(
            children: [
              GlobalImage(assetPath: ImageConstants.haroldFailed, width: 157.w, height: 380.h, fit: BoxFit.contain),
              SizedBox(height: DimensionConstants.gap26Px.h),
              TranslatedText(
                AppStrings.yourMatterFallsOutsideScope,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AuthButton(text: AppStrings.goToHome, onPressed: () => context.go(AppRoutes.homeRouteName), isLoading: false, isEnabled: true),
              SizedBox(height: DimensionConstants.gap10Px.h),
            ],
          ),
        ),
      ),
    );
  }
}
