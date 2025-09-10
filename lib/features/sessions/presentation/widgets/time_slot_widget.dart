import 'package:flutter/material.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';

class TimeSlotWidget extends StatelessWidget {
  final String timeText;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotWidget({super.key, required this.timeText, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap10Px.h, horizontal: DimensionConstants.gap6Px.w),
        decoration: BoxDecoration(
          color: isSelected ? context.darkSecondary : context.filledBgDark,
          borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
          border: isSelected ? null : Border.all(color: context.gradientBgDark, width: 1),
        ),
        child: Row(
          children: [
            GlobalImage(
              assetPath: ImageConstants.clock,
              width: DimensionConstants.gap20Px.w,
              height: DimensionConstants.gap20Px.h,
              fit: BoxFit.contain,
              showLoading: false,
              showError: false,
              fadeIn: false,
              color: isSelected ? context.textPrimary : context.darkTextPrimary,
            ),

            SizedBox(width: DimensionConstants.gap12Px.w),
            Expanded(
              child: Text(
                timeText,
                style: TextStyle(
                  color: isSelected ? context.textPrimary : context.darkTextPrimary,
                  fontSize: DimensionConstants.font14Px.f,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
