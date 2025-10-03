import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/rating_widget.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/constants/image_constants.dart';

class AddRatingReviewWidget extends StatefulWidget {
  final VoidCallback? onSubmit;
  final ValueChanged<double>? onRatingChanged;
  final ValueChanged<String>? onReviewChanged;
  final ValueNotifier<bool>? isExpanded;

  const AddRatingReviewWidget({super.key, this.onSubmit, this.onRatingChanged, this.onReviewChanged, this.isExpanded});

  @override
  State<AddRatingReviewWidget> createState() => _AddRatingReviewWidgetState();
}

class _AddRatingReviewWidgetState extends State<AddRatingReviewWidget> {
  late final ValueNotifier<double> _ratingNotifier;
  late final TextEditingController _reviewController;
  late final ValueNotifier<bool> _localExpansionNotifier;

  @override
  void initState() {
    super.initState();
    _ratingNotifier = ValueNotifier<double>(0.0);
    _reviewController = TextEditingController();
    _localExpansionNotifier = ValueNotifier<bool>(false);

    _ratingNotifier.addListener(() {
      widget.onRatingChanged?.call(_ratingNotifier.value);
    });

    _reviewController.addListener(() {
      widget.onReviewChanged?.call(_reviewController.text);
    });
  }

  @override
  void dispose() {
    _ratingNotifier.dispose();
    _reviewController.dispose();
    _localExpansionNotifier.dispose();
    super.dispose();
  }

  ValueNotifier<bool> get _expansionNotifier => widget.isExpanded ?? _localExpansionNotifier;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _expansionNotifier.value = !_expansionNotifier.value;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _expansionNotifier,
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
                      AppStrings.addYourRatingAndReview,
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
                      SizedBox(height: DimensionConstants.gap16Px.h),
                      ValueListenableBuilder<double>(
                        valueListenable: _ratingNotifier,
                        builder: (context, rating, child) {
                          return RatingWidget(
                            rating: rating,
                            size: DimensionConstants.gap32Px.w,
                            onRatingChanged: (newRating) {
                              _ratingNotifier.value = newRating;
                            },
                          );
                        },
                      ),
                      SizedBox(height: DimensionConstants.gap16Px.h),
                      TranslatedText(
                        AppStrings.addACommentOptional,
                        style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: DimensionConstants.gap8Px.h),
                      Container(
                        decoration: BoxDecoration(color: context.bgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r)),
                        child: TextField(
                          controller: _reviewController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: AppStrings.theAttorneyWasVeryHelpful.tr(),
                            hintStyle: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap12Px.w, vertical: DimensionConstants.gap12Px.h),
                          ),
                          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f),
                        ),
                      ),
                      SizedBox(height: DimensionConstants.gap20Px.h),
                      SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<double>(
                          valueListenable: _ratingNotifier,
                          builder: (context, rating, child) {
                            return CustomButton(
                              onPressed: rating > 0 ? widget.onSubmit : null,
                              backgroundColor: context.primary,
                              disabledBackgroundColor: context.buttonDisabled,
                              textColor: Colors.white,
                              borderRadius: DimensionConstants.radius52Px.r,
                              padding: 16.0,
                              child: TranslatedText(
                                AppStrings.submit,
                                style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            );
                          },
                        ),
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
