import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/session_datetime_utils.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../config/routes/app_routes.dart';
import '../pages/params/session_details_screen_params.dart';
import '../../domain/entities/session_entity.dart';

class SessionCard extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback? onCancel;
  final VoidCallback? onJoin;

  const SessionCard({super.key, required this.session, this.onCancel, this.onJoin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSessionDetails(context),
      child: Container(
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
                        SessionDateTimeUtils.formatSessionDate(session.scheduledDateTime),
                        style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                      ),
                      SizedBox(height: DimensionConstants.gap2Px.h),
                      Text(
                        '(${session.formattedDuration} ${AppStrings.session})',
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
                      session.formattedHoldAmount,
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: DimensionConstants.gap2Px.h),
                    TranslatedText(
                      session.isCompleted ? AppStrings.charged : AppStrings.holdAmountChargedAfterSession,
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                    ),
                  ],
                ),
              ],
            ),

            if (session.isUpcoming) ...[
              SizedBox(height: DimensionConstants.gap16Px.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: (session.cancelTimeExpired == true) ? null : onCancel,
                      backgroundColor: context.buttonSecondary,
                      disabledBackgroundColor: context.buttonDisabled,
                      textColor: context.darkTextPrimary,
                      borderRadius: DimensionConstants.radius52Px.r,
                      padding: 12.0,
                      child: TranslatedText(
                        AppStrings.cancelSession,
                        style: TextStyle(
                          fontSize: DimensionConstants.font16Px.f,
                          fontWeight: FontWeight.w600,
                          color: (session.cancelTimeExpired == true) ? context.darkTextSecondary : context.darkTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DimensionConstants.gap12Px.w),
                  Expanded(
                    child: CustomButton(
                      onPressed: onJoin,
                      backgroundColor: context.primary,
                      textColor: Colors.white,
                      borderRadius: DimensionConstants.radius52Px.r,
                      padding: 12.0,
                      child: TranslatedText(
                        AppStrings.joinSession,
                        style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (session.isUpcoming && session.cancelTimeExpired == false) ...[
              SizedBox(height: DimensionConstants.gap12Px.h),
              Text(
                '${AppStrings.youCanCancelTill.tr()} ${SessionDateTimeUtils.formatCancelTime(session.cancelTime)}.',
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
              ).tr(),
            ],

            if (session.isUpcoming && session.cancelTimeExpired == true) ...[
              SizedBox(height: DimensionConstants.gap12Px.h),
              TranslatedText(
                AppStrings.cancellationPeriodExpired,
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.red, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: DimensionConstants.gap4Px.h),
              Text(
                '${AppStrings.youCouldHaveCanceled.tr()} ${SessionDateTimeUtils.formatCancelTime(session.cancelTime)}.',
                style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                textAlign: TextAlign.center,
              ).tr(),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToSessionDetails(BuildContext context) {
    context.push(AppRoutes.sessionDetailsRouteName, extra: SessionDetailsScreenParams(session: session));
  }
}
