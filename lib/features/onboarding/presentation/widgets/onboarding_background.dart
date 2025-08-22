import 'package:flutter/material.dart';
import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlobalImage(assetPath: ImageConstants.splash, height: double.infinity, width: double.infinity),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.9)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
