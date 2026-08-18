import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/session_datetime_utils.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/constants/image_constants.dart';
import '../../domain/entities/user_session_request_entity.dart';

class SessionRequestCard extends StatelessWidget {
  final UserSessionRequestEntity request;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const SessionRequestCard({super.key, required this.request, this.onCancel, this.onReschedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: DimensionConstants.gap16Px.h),
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap12Px.w, vertical: DimensionConstants.gap16Px.h),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                      SessionDateTimeUtils.formatSessionDate(request.scheduledDateTime, endDateTime: request.endDateTime),
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: DimensionConstants.gap2Px.h),
                    Text(
                      '(${request.formattedDuration} ${AppStrings.session})',
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                    ).tr(),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: DimensionConstants.gap16Px.h),

          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.sessionPrice,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.isFreeSession ? '\$0.00' : request.formattedHoldAmount,
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: DimensionConstants.gap2Px.h),
                  TranslatedText(
                    AppStrings.holdAmountChargedAfterSession,
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                  ),
                ],
              ),
            ],
          ),

          if (onCancel != null) ...[
            SizedBox(height: DimensionConstants.gap16Px.h),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: onCancel,
                backgroundColor: context.buttonSecondary,
                disabledBackgroundColor: context.buttonDisabled,
                textColor: context.darkTextPrimary,
                borderRadius: DimensionConstants.radius52Px.r,
                padding: DimensionConstants.gap12Px.d,
                child: TranslatedText(
                  AppStrings.cancelSession,
                  style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                ),
              ),
            ),
            SizedBox(height: DimensionConstants.gap8Px.h),
            TranslatedText(
              AppStrings.cancellationPolicyNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: DimensionConstants.font12Px.f, color: context.darkTextSecondary),
            ),
          ],

          if (onReschedule != null) ...[
            SizedBox(height: DimensionConstants.gap16Px.h),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: onReschedule,
                backgroundColor: context.buttonSecondary,
                disabledBackgroundColor: context.buttonDisabled,
                textColor: context.darkTextPrimary,
                borderRadius: DimensionConstants.radius52Px.r,
                padding: DimensionConstants.gap12Px.d,
                child: TranslatedText(
                  AppStrings.rescheduleSession,
                  style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
