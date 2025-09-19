import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/image_constants.dart';
import '../../domain/entities/session_entity.dart';

class SessionCard extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback? onCancel;
  final VoidCallback? onJoin;

  const SessionCard({super.key, required this.session, this.onCancel, this.onJoin});

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
                      _formatSessionDate(session.scheduledDate),
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '(${session.formattedDuration} ${AppStrings.session.tr()})',
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
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
                    session.formattedPrice,
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    session.isCompleted ? AppStrings.charged.tr() : AppStrings.holdAmountChargedAfterSession.tr(),
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
                    onPressed: onCancel,
                    backgroundColor: context.buttonSecondary,
                    disabledBackgroundColor: context.buttonDisabled,
                    textColor: context.darkTextPrimary,
                    borderRadius: 50.r,
                    padding: 12.0,
                    child: Text(
                      AppStrings.cancelSession.tr(),
                      style: TextStyle(
                        fontSize: DimensionConstants.font16Px.f,
                        fontWeight: FontWeight.w600,
                        color: onCancel != null ? context.darkTextPrimary : context.darkTextSecondary,
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
                    borderRadius: 50.r,
                    padding: 12.0,
                    child: Text(
                      AppStrings.joinSession.tr(),
                      style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (session.isUpcoming && session.canCancel) ...[
            SizedBox(height: DimensionConstants.gap12Px.h),
            Text(
              '${AppStrings.youCanCancelTill.tr()} ${_formatCancellationDeadline(session.scheduledDate)}.',
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
            ),
          ],

          if (session.isUpcoming && !session.canCancel) ...[
            SizedBox(height: DimensionConstants.gap12Px.h),
            Text(
              AppStrings.cancellationPeriodExpired.tr(),
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.red, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4.h),
            Text(
              '${AppStrings.youCouldHaveCanceled.tr()} ${_formatCancellationDeadline(session.scheduledDate)}.',
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return '${AppStrings.today.tr()}, ${DateFormat('MMM d').format(date)} – ${DateFormat('h:mm A').format(date)} to ${DateFormat('h:mm A').format(date.add(Duration(minutes: 30)))}';
    } else {
      return '${DateFormat('EEEE, MMM d').format(date)} – ${DateFormat('h:mm A').format(date)} to ${DateFormat('h:mm A').format(date.add(Duration(minutes: 30)))}';
    }
  }

  String _formatCancellationDeadline(DateTime sessionDate) {
    final deadline = sessionDate.subtract(const Duration(hours: 24));
    return '${DateFormat('dd/MM/yy').format(deadline)}, ${DateFormat('h:mm A').format(deadline)}';
  }
}
