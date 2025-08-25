import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/onboarding_background.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/gradient_border_painter.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(padding: EdgeInsets.only(left: 8.w), child: CustomBackButton()),
      ),
      body: OnboardingBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                TranslatedText(AppStrings.aboutUs, style: TextStyle(color: Colors.white, fontSize: 24.f, fontWeight: FontWeight.w700)),
                TranslatedText(
                  AppStrings.learnAboutUsAndOurTeam,
                  style: TextStyle(color: Colors.white, fontSize: 14.f, fontWeight: FontWeight.w400, height: 1.5),
                ),
                SizedBox(height: 25.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildCassiusTitusCard(), SizedBox(height: 30.h), _buildTeamSection()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCassiusTitusCard() {
    return SizedBox(
      width: double.infinity,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: CustomPaint(
            painter: RoundedGradientBorderPainter(backgroundColor: Colors.black.withValues(alpha: 0.4), borderRadius: 20.r),
            child: Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 99.w,
                    height: 99.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                      image: const DecorationImage(image: AssetImage(ImageConstants.client1), fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TranslatedText(
                    AppStrings.cassiusTitusDescription,
                    style: TextStyle(color: Colors.white, fontSize: 14.f, fontWeight: FontWeight.w400, height: 1.5),
                  ),
                ],
              ),
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
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 24.h,
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
            image: DecorationImage(image: AssetImage(member['image']!), fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 8.h),
        TranslatedText(
          member['name']!,
          style: TextStyle(color: Colors.white, fontSize: 12.f, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        TranslatedText(
          member['title']!,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.f, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
