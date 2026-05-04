import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'gradient_border_painter.dart';

class OnboardingCustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;
  final double borderWidth;

  const OnboardingCustomBackButton({
    super.key,
    this.onPressed,
    this.size = 44,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.iconColor = Colors.white,
    this.borderColor = const Color(0xFF333333),
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desiredSize = size.w;
        final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : desiredSize;
        final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : desiredSize;
        final effectiveSize = math.min(desiredSize, math.min(maxWidth, maxHeight));

        return SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: CustomPaint(
            painter: GradientBorderPainter(backgroundColor: backgroundColor, borderColor: borderColor, borderWidth: borderWidth),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed ?? () => context.pop(),
                borderRadius: BorderRadius.circular(effectiveSize / 2),
                child: Center(child: Icon(Icons.arrow_back, color: iconColor, size: effectiveSize * 0.5)),
              ),
            ),
          ),
        );
      },
    );
  }
}
