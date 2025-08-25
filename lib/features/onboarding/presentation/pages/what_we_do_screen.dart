import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/custom_back_button.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/gradient_border_painter.dart';

class WhatWeDoScreen extends StatelessWidget {
  const WhatWeDoScreen({super.key});

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
        imagePath: ImageConstants.whatWeDoBG,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                TranslatedText(
                  AppStrings.whatWeDo,
                  style: TextStyle(color: Colors.white, fontSize: 24.f, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                TranslatedText(
                  AppStrings.whatWeDoDescription,
                  style: TextStyle(color: Colors.white, fontSize: 14.f, fontWeight: FontWeight.w400, height: 1.5),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: ListView.separated(
                    itemCount: 5,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) => SizedBox(height: 6.h),
                    itemBuilder: (context, index) {
                      return _buildServiceCardByIndex(index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCardByIndex(int index) {
    final serviceData = [
      {'imagePath': ImageConstants.musicLicensing, 'title': AppStrings.musicLicensing, 'description': AppStrings.musicLicensingDescription},
      {
        'imagePath': ImageConstants.visualArtistsRights,
        'title': AppStrings.visualArtistsRights,
        'description': AppStrings.visualArtistsRightsDescription,
      },
      {'imagePath': ImageConstants.videoAndMedia, 'title': AppStrings.videoAndMedia, 'description': AppStrings.videoAndMediaDescription},
      {
        'imagePath': ImageConstants.artificialIntelligence,
        'title': AppStrings.artificialIntelligence,
        'description': AppStrings.artificialIntelligenceDescription,
      },
      {'imagePath': ImageConstants.writers, 'title': AppStrings.writers, 'description': AppStrings.writersDescription},
    ];

    final data = serviceData[index];
    return _buildServiceCard(imagePath: data['imagePath']!, title: data['title']!, description: data['description']!);
  }

  Widget _buildServiceCard({required String imagePath, required String title, required String description}) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: CustomPaint(
            painter: RoundedGradientBorderPainter(backgroundColor: Colors.black.withValues(alpha: 0.5), borderRadius: 16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24.r)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: GlobalImage(assetPath: imagePath, width: 48.w, height: 48.w, fit: BoxFit.cover, showLoading: false, showError: false),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(title, style: TextStyle(color: Colors.white, fontSize: 16.f, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4.h),
                        TranslatedText(
                          description,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14.f, fontWeight: FontWeight.w400, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
