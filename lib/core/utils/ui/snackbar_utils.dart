import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  SnackBarUtils._();

  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
    _showCustomSnackBar(
      context,
      message: message,
      imagePath: ImageConstants.snackbarSuccess,
      backgroundColor: const Color(0xFF4CAF50),
      duration: duration,
    );
  }

  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 3), bool showDismissAction = true}) {
    _showCustomSnackBar(
      context,
      message: message,
      imagePath: ImageConstants.snackbarError,
      backgroundColor: const Color(0xFFF44336),
      duration: duration,
      showDismissAction: showDismissAction,
    );
  }

  static void _showCustomSnackBar(
    BuildContext context, {
    required String message,
    required String imagePath,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
    bool showDismissAction = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.paddingOf(context).top + DimensionConstants.gap10Px.h,
            left: DimensionConstants.gap16Px.w,
            right: DimensionConstants.gap16Px.w,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _CustomSnackBarContent(
                        message: message,
                        imagePath: imagePath,
                        showDismissAction: showDismissAction,
                        onDismiss: () => overlayEntry.remove(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _CustomSnackBarContent extends StatelessWidget {
  final String message;
  final String imagePath;
  final bool showDismissAction;
  final VoidCallback? onDismiss;

  const _CustomSnackBarContent({required this.message, required this.imagePath, this.showDismissAction = false, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isError = imagePath == ImageConstants.snackbarError;
    final backgroundColor = isError ? const Color(0xFF2D3748) : const Color(0xFF2D3748);
    final iconColor = isError ? const Color(0xFFF56565) : const Color(0xFF68D391);

    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          GlobalImage(
            assetPath: imagePath,
            width: DimensionConstants.gap24Px.w,
            height: DimensionConstants.gap24Px.h,
            fit: BoxFit.contain,
            showLoading: false,
            showError: false,
            fadeIn: false,
          ),

          SizedBox(width: DimensionConstants.gap12Px.w),

          Expanded(child: Text(message, style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500))),

          if (showDismissAction)
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: EdgeInsets.all(DimensionConstants.gap4Px.w),
                child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.7), size: DimensionConstants.gap16Px.w),
              ),
            ),
        ],
      ),
    );
  }
}
