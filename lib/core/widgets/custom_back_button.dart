import 'package:flutter/material.dart';
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
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(color: backgroundColor.withValues(alpha: 0.6), shape: BoxShape.circle),
      child: InkWell(
        onTap: onPressed ?? () => context.pop(),
        borderRadius: BorderRadius.circular((size / 2).w),
        child: Center(child: Icon(Icons.arrow_back, color: iconColor, size: (size * 0.5).w)),
      ),
    );
  }
}
