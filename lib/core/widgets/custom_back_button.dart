import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../utils/extensions/responsive_extensions.dart';

class CustomBackButton extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color iconColor;
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.size = 40,
    this.backgroundColor = Colors.black,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.iconColor = Colors.white,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desiredSize = size.w;
        final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : desiredSize;
        final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : desiredSize;
        final effectiveSize = math.min(desiredSize, math.min(maxWidth, maxHeight));

        return Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(color: backgroundColor.withValues(alpha: 0.6), shape: BoxShape.circle),
          child: InkWell(
            onTap: onPressed ?? () => context.pop(),
            borderRadius: BorderRadius.circular(effectiveSize / 2),
            child: Center(child: Icon(Icons.arrow_back, color: iconColor, size: effectiveSize * 0.5)),
          ),
        );
      },
    );
  }
}
