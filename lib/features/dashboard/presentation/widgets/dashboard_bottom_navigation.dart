import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';

class DashboardBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardBottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.backgroundColor, border: Border(top: BorderSide(color: context.border, width: 1))),
      child: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.backgroundColor,
        selectedItemColor: context.primary,
        unselectedItemColor: context.darkTextSecondary,
        selectedFontSize: DimensionConstants.font12Px.f,
        unselectedFontSize: DimensionConstants.font12Px.f,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: DimensionConstants.gap24Px.w),
            activeIcon: Icon(Icons.home, size: DimensionConstants.gap24Px.w),
            label: AppStrings.home.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined, size: DimensionConstants.gap24Px.w),
            activeIcon: Icon(Icons.event_note, size: DimensionConstants.gap24Px.w),
            label: AppStrings.mySessions.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: DimensionConstants.gap24Px.w),
            activeIcon: Icon(Icons.person, size: DimensionConstants.gap24Px.w),
            label: AppStrings.profile.tr(),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }
}
