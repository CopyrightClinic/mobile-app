import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/onboarding_background.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/gradient_border_painter.dart';
import '../widgets/custom_back_button.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(leading: OnboardingCustomBackButton(), leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w)),
      body: OnboardingBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                SizedBox(height: DimensionConstants.gap16Px.h),
                _buildCassiusProfileCard(),
                SizedBox(height: DimensionConstants.gap12Px.h),
                Expanded(child: _buildDescriptionCard()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: DimensionConstants.gap10Px.h),
        TranslatedText(
          AppStrings.aboutUs,
          style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: DimensionConstants.gap4Px.h),
        TranslatedText(
          AppStrings.learnAboutUsAndOurTeam,
          style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCassiusProfileCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 99.w,
            height: 99.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(image: AssetImage(ImageConstants.casius), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: DimensionConstants.gap10Px.h),
          Text(
            AppStrings.cassiusTitusName,
            style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _buildGlassCard(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TranslatedText(
          AppStrings.cassiusTitusDescriptionUpdated,
          style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, height: 1.5),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: CustomPaint(
          painter: RoundedGradientBorderPainter(backgroundColor: Colors.black.withValues(alpha: 0.4), borderRadius: 20.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(DimensionConstants.gap16Px),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
            child: child,
          ),
        ),
      ),
    );
  }
}
