import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/extensions.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: DimensionConstants.gap16Px.h),
        decoration: BoxDecoration(
          color: notification.isRead ? context.filledBgDark : context.filledBgDark.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r),
          border: notification.isRead ? null : Border.all(color: context.primary.withValues(alpha: 0.2), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!notification.isRead)
                Container(
                  margin: EdgeInsets.only(right: DimensionConstants.gap12Px.w, top: DimensionConstants.gap6Px.h),
                  width: DimensionConstants.gap8Px.w,
                  height: DimensionConstants.gap8Px.w,
                  decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: context.darkTextPrimary,
                        fontSize: DimensionConstants.font16Px.f,
                        fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: DimensionConstants.gap8Px.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: context.darkTextSecondary,
                        fontSize: DimensionConstants.font14Px.f,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: DimensionConstants.gap12Px.w),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font12Px.f, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow.tr();
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}
