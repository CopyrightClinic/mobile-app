import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/translated_text.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(titleText: AppStrings.mySessions.tr(), automaticallyImplyLeading: false),
      body: Padding(
        padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note_outlined, size: DimensionConstants.gap64Px.w, color: context.darkTextSecondary),
                    SizedBox(height: DimensionConstants.gap24Px.h),
                    TranslatedText(
                      AppStrings.noUpcomingSessions,
                      style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w500, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: DimensionConstants.gap8Px.h),
                    TranslatedText(
                      'You haven\'t booked any sessions yet.',
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
