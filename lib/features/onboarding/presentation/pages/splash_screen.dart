import 'package:flutter/material.dart';
import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/responsive_extensions.dart';
import 'package:copyright_clinic_flutter/features/onboarding/presentation/widgets/onboarding_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlobalImage(assetPath: ImageConstants.logo, width: 105.8.w),
              Text('Copyright Clinic', style: TextStyle(color: Colors.white, fontSize: 24.f, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
