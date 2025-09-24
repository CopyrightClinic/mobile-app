import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../domain/entities/session_availability_entity.dart';

class DaySelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<AvailabilityDayEntity> availableDays;
  final ValueChanged<DateTime> onDateSelected;

  const DaySelectorWidget({super.key, required this.selectedDate, required this.availableDays, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    if (availableDays.isEmpty) {
      return const DaySelectorShimmer();
    }

    final dayNames = [AppStrings.mon, AppStrings.tue, AppStrings.wed, AppStrings.thu, AppStrings.fri, AppStrings.sat, AppStrings.sun];

    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDays.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final dayEntity = availableDays[index];
          final date = dayEntity.date;
          final isSelected = _isSameDay(date, selectedDate);
          final dayName = dayNames[date.weekday - 1];
          final hasSlots = dayEntity.slots.isNotEmpty;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 45.w,
              margin: EdgeInsets.only(right: index < availableDays.length - 1 ? DimensionConstants.gap8Px.w : 0),
              padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap12Px.h, horizontal: DimensionConstants.gap8Px.w),
              decoration: BoxDecoration(
                color: isSelected ? context.darkSecondary : (hasSlots ? context.filledBgDark : context.filledBgDark.withOpacity(0.7)),
                borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TranslatedText(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? context.textPrimary : (hasSlots ? context.white : context.darkTextPrimary.withOpacity(0.8)),
                      fontSize: DimensionConstants.font14Px.f,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: DimensionConstants.gap4Px.h),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? context.textPrimary : (hasSlots ? context.darkTextPrimary : context.darkTextPrimary.withOpacity(0.8)),
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
