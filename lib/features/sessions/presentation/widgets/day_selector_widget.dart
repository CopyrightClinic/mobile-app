import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/translated_text.dart';

class DaySelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DaySelectorWidget({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(30, (index) => now.add(Duration(days: index)));
    final dayNames = [AppStrings.mon, AppStrings.tue, AppStrings.wed, AppStrings.thu, AppStrings.fri, AppStrings.sat, AppStrings.sun];

    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          final dayName = dayNames[date.weekday - 1];

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 45.w,
              margin: EdgeInsets.only(right: index < dates.length - 1 ? DimensionConstants.gap8Px.w : 0),
              padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap12Px.h, horizontal: DimensionConstants.gap8Px.w),
              decoration: BoxDecoration(
                color: isSelected ? context.darkSecondary : context.filledBgDark,
                borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TranslatedText(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? context.textPrimary : context.white,
                      fontSize: DimensionConstants.font14Px.f,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: DimensionConstants.gap4Px.h),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? context.textPrimary : context.darkTextPrimary,
                      fontSize: DimensionConstants.font14Px.f,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
