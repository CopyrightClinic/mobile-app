import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/global_image.dart';

class SubmittedRatingReviewWidget extends StatelessWidget {
  final double rating;
  final String? review;
  final ValueNotifier<bool> isExpanded;

  const SubmittedRatingReviewWidget({super.key, required this.rating, this.review, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isExpanded.value = !isExpanded.value;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isExpanded,
        builder: (context, expanded, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
            decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TranslatedText(
                      AppStrings.yourRatingAndReview,
                      style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        GlobalImage(
                          assetPath: ImageConstants.starFilled,
                          width: DimensionConstants.gap16Px.w,
                          height: DimensionConstants.gap16Px.w,
                          fit: BoxFit.contain,
                          showLoading: false,
                          showError: false,
                          fadeIn: false,
                        ),
                        SizedBox(width: DimensionConstants.gap4Px.w),
                        Text(
                          '($rating)',
                          style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: DimensionConstants.gap8Px.w),
                        AnimatedRotation(
                          turns: expanded ? 0.0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_up, color: context.darkTextSecondary, size: DimensionConstants.gap20Px.w),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: DimensionConstants.gap12Px.h),
                      Text(
                        review ?? AppStrings.noReviewProvided.tr(),
                        style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
