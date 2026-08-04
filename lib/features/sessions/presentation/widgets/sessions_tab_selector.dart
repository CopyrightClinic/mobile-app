import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';

class SessionsTabSelector extends StatelessWidget {
  final SessionsTab currentTab;
  final ValueChanged<SessionsTab> onTabSelected;

  const SessionsTabSelector({super.key, required this.currentTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(color: Colors.white.withAlpha(5), borderRadius: BorderRadius.circular(DimensionConstants.radius48Px.r)),
      child: Row(
        children: SessionsTab.values.map((tab) => Expanded(child: _buildTab(context, tab))).toList(),
      ),
    );
  }

  Widget _buildTab(BuildContext context, SessionsTab tab) {
    final isSelected = tab == currentTab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? context.darkSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(DimensionConstants.radius48Px.r),
        ),
        child: Center(
          child: Text(
            tab.displayName.tr(),
            style: TextStyle(
              fontSize: DimensionConstants.font13Px.f,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? context.textPrimary : context.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
