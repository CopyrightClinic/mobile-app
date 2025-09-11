import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';

class DashboardBottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardBottomNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.w),
      child: Container(
        color: context.bottomNavBarBG,
        child: SafeArea(
          child: SizedBox(
            height: 80.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, ImageConstants.home, ImageConstants.homeFill, AppStrings.home.tr()),
                _buildNavItem(context, 1, ImageConstants.sessions, ImageConstants.sessionsFill, AppStrings.mySessions.tr()),
                _buildNavItem(context, 2, ImageConstants.profile, ImageConstants.profileFill, AppStrings.profile.tr()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String iconPath, String activeIconPath, String label) {
    final bool isSelected = navigationShell.currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Container(
        width: 80.w,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 12.h),
            GlobalImage(
              assetPath: isSelected ? activeIconPath : iconPath,
              width: DimensionConstants.gap24Px.w,
              height: DimensionConstants.gap24Px.w,
              fit: BoxFit.contain,
              showLoading: false,
              showError: false,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: DimensionConstants.font12Px.f,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? context.darkSecondary : context.darkTextSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 6.w,
              height: 3.h,
              decoration: BoxDecoration(color: isSelected ? context.darkSecondary : Colors.transparent, borderRadius: BorderRadius.circular(1.w)),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }
}
