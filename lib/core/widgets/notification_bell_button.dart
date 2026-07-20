import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_state.dart';
import '../constants/dimensions.dart';
import '../utils/extensions/responsive_extensions.dart';
import '../utils/extensions/theme_extensions.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DimensionConstants.gap40Px.d,
      height: DimensionConstants.gap40Px.d,
      decoration: BoxDecoration(color: context.bgDark.withValues(alpha: 0.7), shape: BoxShape.circle),
      child: InkWell(
        onTap: () {
          context.pushNamed(AppRoutes.notificationsRouteName);
        },
        borderRadius: BorderRadius.circular((DimensionConstants.gap40Px.d / 2).d),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: Icon(Icons.notifications_outlined, color: context.darkTextPrimary, size: (DimensionConstants.gap40Px * 0.5).d),
            ),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final hasUnread = state is NotificationLoaded && state.notifications.any((n) => !n.isRead);
                if (!hasUnread) return const SizedBox.shrink();
                return Positioned(
                  top: DimensionConstants.gap8Px.d,
                  right: DimensionConstants.gap8Px.d,
                  child: Container(
                    width: DimensionConstants.gap10Px.d,
                    height: DimensionConstants.gap10Px.d,
                    decoration: BoxDecoration(
                      color: context.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.bgDark, width: 1.5.w),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
