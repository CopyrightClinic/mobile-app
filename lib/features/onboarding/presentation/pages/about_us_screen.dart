import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/onboarding_background.dart';
import '../../../../core/widgets/custom_app_bar.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DimensionConstants.gap10Px.h),
                    TranslatedText(
                      AppStrings.aboutUs,
                      style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
                    ),
                    TranslatedText(
                      AppStrings.learnAboutUsAndOurTeam,
                      style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, height: 1.5),
                    ),
                    SizedBox(height: DimensionConstants.gap24Px.h),
                  ],
                ),
              ),
              Expanded(child: _buildCassiusSection()),
            ],
          ),
        ),
      ),
    );
  }

  EdgeInsets get _cassiusSectionMargin => EdgeInsets.symmetric(horizontal: DimensionConstants.gap12Px.w, vertical: DimensionConstants.gap12Px.h);

  Widget _buildCassiusSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final margin = _cassiusSectionMargin;
        final contentWidth = constraints.maxWidth - margin.horizontal - 16.w;
        final contentHeight = constraints.maxHeight - margin.vertical - 12.h;

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Padding(
                padding: margin,
                child: Image.asset(
                  ImageConstants.casius,
                  width: contentWidth,
                  height: contentHeight,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned(left: margin.left, right: margin.right, top: margin.top, bottom: margin.bottom, child: _buildDescriptionOverlay()),
          ],
        );
      },
    );
  }

  Widget _buildDescriptionOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap20Px.w, vertical: DimensionConstants.gap20Px.h),
            child: TranslatedText(
              AppStrings.cassiusTitusDescriptionUpdated,
              style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, height: 1.5),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: DimensionConstants.gap16Px.w,
        mainAxisSpacing: DimensionConstants.gap24Px.h,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildTeamMemberCard(index);
      },
    );
  }

  Widget _buildTeamMemberCard(int index) {
    final teamMembers = [
      {'name': AppStrings.sarahChen, 'title': AppStrings.seniorAttorney, 'image': ImageConstants.client2},
      {'name': AppStrings.michaelRoss, 'title': AppStrings.legalCounsel, 'image': ImageConstants.client3},
      {'name': AppStrings.emmaWilson, 'title': AppStrings.ipSpecialist, 'image': ImageConstants.client4},
      {'name': AppStrings.sarahChen, 'title': AppStrings.legalAdvisor, 'image': ImageConstants.client5},
      {'name': AppStrings.michaelRoss, 'title': AppStrings.copyrightExpert, 'image': ImageConstants.client6},
      {'name': AppStrings.emmaWilson, 'title': AppStrings.legalAnalyst, 'image': ImageConstants.client7},
    ];

    final member = teamMembers[index];

    return Column(
      children: [
        Container(
          width: 87.w,
          height: 87.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.r),
            image: DecorationImage(image: AssetImage(member['image'] ?? ''), fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: DimensionConstants.gap8Px.h),
        TranslatedText(
          member['title'] ?? '',
          style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font12Px.f, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
