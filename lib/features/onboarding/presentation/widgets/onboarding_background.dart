import 'package:flutter/material.dart';
import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const OnboardingBackground({super.key, required this.child, this.imagePath = ImageConstants.splash});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlobalImage(assetPath: imagePath, height: double.infinity, width: double.infinity),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.45), Colors.black.withValues(alpha: 0.9)],
              stops: const [0.01, 0.5, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
