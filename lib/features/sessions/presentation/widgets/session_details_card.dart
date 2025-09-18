import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/constants/image_constants.dart';

class SessionDetailsCard extends StatelessWidget {
  final DateTime sessionDate;
  final String? timeSlot;

  const SessionDetailsCard({super.key, required this.sessionDate, this.timeSlot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DimensionConstants.gap24Px.h),
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.sessionTime,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatSessionDateTime(sessionDate, timeSlot),
                      style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: DimensionConstants.gap2Px.h),
                    TranslatedText(
                      AppStrings.thirtyMinutesSession,
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, color: context.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: DimensionConstants.gap16Px.h),

          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.mic,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: TranslatedText(
                  AppStrings.recordingConsented,
                  style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, color: context.darkTextSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSessionDateTime(DateTime date, String? timeSlot) {
    final dayName = DateFormat('EEEE').format(date);
    final monthDay = DateFormat('MMM d').format(date);

    String startTime;
    String endTime;

    if (timeSlot != null && timeSlot.isNotEmpty) {
      try {
        final regex = RegExp(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z?)-(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z?)');
        final match = regex.firstMatch(timeSlot);

        if (match != null && match.groupCount == 2) {
          final startDateTime = DateTime.parse(match.group(1)!);
          final endDateTime = DateTime.parse(match.group(2)!);

          startTime = DateFormat('h:mm a').format(startDateTime);
          endTime = DateFormat('h:mm a').format(endDateTime);
        } else {
          startTime = DateFormat('h:mm a').format(date);
          endTime = DateFormat('h:mm a').format(date.add(const Duration(minutes: 30)));
        }
      } catch (e) {
        startTime = DateFormat('h:mm a').format(date);
        endTime = DateFormat('h:mm a').format(date.add(const Duration(minutes: 30)));
      }
    } else {
      startTime = DateFormat('h:mm a').format(date);
      endTime = DateFormat('h:mm a').format(date.add(const Duration(minutes: 30)));
    }

    return '$dayName, $monthDay – $startTime to $endTime';
  }
}
