import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';

class SessionsTabSelector extends StatelessWidget {
  final bool isUpcomingSelected;
  final VoidCallback onUpcomingTap;
  final VoidCallback onCompletedTap;

  const SessionsTabSelector({super.key, required this.isUpcomingSelected, required this.onUpcomingTap, required this.onCompletedTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(color: Colors.white.withAlpha(5), borderRadius: BorderRadius.circular(DimensionConstants.radius48Px.r)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onUpcomingTap,
              child: Container(
                decoration: BoxDecoration(
                  color: isUpcomingSelected ? context.darkSecondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(DimensionConstants.radius48Px.r),
                ),
                child: Center(
                  child: Text(
                    AppStrings.upcoming.tr(),
                    style: TextStyle(
                      fontSize: DimensionConstants.font13Px.f,
                      fontWeight: isUpcomingSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isUpcomingSelected ? context.textPrimary : context.darkTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onCompletedTap,
              child: Container(
                decoration: BoxDecoration(
                  color: !isUpcomingSelected ? context.darkSecondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(DimensionConstants.radius48Px.r),
                ),
                child: Center(
                  child: Text(
                    AppStrings.completed.tr(),
                    style: TextStyle(
                      fontSize: DimensionConstants.font13Px.f,
                      fontWeight: !isUpcomingSelected ? FontWeight.w600 : FontWeight.w400,
                      color: !isUpcomingSelected ? context.textPrimary : context.darkTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
