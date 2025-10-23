import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/extensions.dart';
import '../../../../core/utils/storage/user_storage.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationBloc _notificationBloc;
  late ScrollController _scrollController;
  final ValueNotifier<String?> _userIdNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _notificationBloc = context.read<NotificationBloc>();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadUserAndNotifications();
  }

  Future<void> _loadUserAndNotifications() async {
    final user = await UserStorage.getUser();
    if (user != null && mounted) {
      _userIdNotifier.value = user.id;
      _notificationBloc.add(LoadNotifications(userId: user.id));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final userId = _userIdNotifier.value;
      if (userId != null) {
        _notificationBloc.add(LoadMoreNotifications(userId: userId));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: const CustomBackButton(),
        centerTitle: true,
        title: TranslatedText(
          AppStrings.notifications,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationError) {
              if (state.message.contains('Failed to mark all as read')) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: context.red));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: context.red));
              }
            }
          },
          builder: (context, state) {
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationState state) {
    if (state is NotificationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NotificationError) {
      return _buildErrorState(context, state.message);
    }

    if (state is NotificationLoaded) {
      final notifications = state.notifications;

      if (notifications.isEmpty) {
        return _buildEmptyState(context);
      }

      final hasUnreadNotifications = notifications.any((notification) => !notification.isRead);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              DimensionConstants.gap16Px.w,
              DimensionConstants.gap16Px.h,
              DimensionConstants.gap16Px.w,
              DimensionConstants.gap8Px.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TranslatedText(
                  AppStrings.today,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                ),
                if (hasUnreadNotifications)
                  TextButton(
                    onPressed: () {
                      _notificationBloc.add(const MarkAllNotificationsAsRead());
                    },
                    child: TranslatedText(
                      AppStrings.markAllAsRead,
                      style: TextStyle(color: context.primaryColor, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<String?>(
              valueListenable: _userIdNotifier,
              builder: (context, userId, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    if (userId != null) {
                      _notificationBloc.add(RefreshNotifications(userId: userId));
                    }
                  },
                  child: child!,
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                itemCount: notifications.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= notifications.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final notification = notifications[index];
                  return NotificationCard(notification: notification, onTap: () {});
                },
              ),
            ),
          ),
        ],
      );
    }

    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      title: AppStrings.noNotifications,
      subtitle: AppStrings.noNotificationsDescription,
      icon: Icons.notifications_outlined,
      iconColor: context.darkTextSecondary,
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: DimensionConstants.gap64Px.w, color: context.red),
          SizedBox(height: DimensionConstants.gap16Px.h),
          Text(
            message,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DimensionConstants.gap24Px.h),
          ValueListenableBuilder<String?>(
            valueListenable: _userIdNotifier,
            builder: (context, userId, child) {
              return ElevatedButton(
                onPressed:
                    userId != null
                        ? () {
                          _notificationBloc.add(LoadNotifications(userId: userId));
                        }
                        : null,
                child: TranslatedText(AppStrings.retry),
              );
            },
          ),
        ],
      ),
    );
  }
}
