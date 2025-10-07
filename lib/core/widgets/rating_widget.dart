import 'package:flutter/material.dart';
import '../constants/image_constants.dart';
import '../utils/extensions/responsive_extensions.dart';
import 'global_image.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double size;
  final bool isInteractive;

  const RatingWidget({super.key, required this.rating, this.onRatingChanged, this.size = 32.0, this.isInteractive = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;

        return GestureDetector(
          onTap: isInteractive ? () => onRatingChanged?.call(starIndex.toDouble()) : null,
          child: GlobalImage(
            assetPath: isFilled ? ImageConstants.starFilled : ImageConstants.starUnfilled,
            width: size.w,
            height: size.w,
            fit: BoxFit.contain,
            showLoading: false,
            showError: false,
            fadeIn: false,
          ),
        );
      }),
    );
  }
}
