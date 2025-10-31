import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/extensions.dart';
import '../../../../core/utils/storage/user_storage.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/enumns/api/notifications_enums.dart';
import '../../../sessions/presentation/pages/params/session_details_screen_params.dart';
import '../../../sessions/presentation/pages/params/extend_session_screen_params.dart';
import '../../data/models/notification_data_model.dart';
import '../../domain/entities/notification_entity.dart';
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
  final ValueNotifier<String> _currentDateLabel = ValueNotifier<String>(AppStrings.today);
  final Map<int, GlobalKey> _itemKeys = {};
  DateTime? _lastTapTime;

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

    _updateCurrentDateLabel();
  }

  void _updateCurrentDateLabel() {
    final state = _notificationBloc.state;
    if (state is! NotificationLoaded || state.notifications.isEmpty) return;

    final notifications = state.notifications;
    final scrollOffset = _scrollController.offset;

    int? visibleIndex = _findFirstVisibleItemIndex(notifications);

    if (visibleIndex == null) {
      if (scrollOffset > 0) {
        final avgItemHeight = 140.0;
        visibleIndex = (scrollOffset / avgItemHeight).floor().clamp(0, notifications.length - 1);
      } else {
        visibleIndex = 0;
      }
    }

    if (visibleIndex < notifications.length) {
      final visibleNotification = notifications[visibleIndex];
      final dateLabel = _getDateLabel(visibleNotification.createdAt);

      if (_currentDateLabel.value != dateLabel) {
        _currentDateLabel.value = dateLabel;
      }
    }
  }

  int? _findFirstVisibleItemIndex(List notifications) {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;

      final listTop = renderBox.localToGlobal(Offset.zero).dy;
      final headerHeight = 120.0;
      final viewportTop = listTop + headerHeight;

      for (int i = 0; i < notifications.length; i++) {
        final key = _itemKeys[i];
        if (key?.currentContext != null) {
          final itemRenderBox = key!.currentContext!.findRenderObject() as RenderBox?;
          if (itemRenderBox != null) {
            final itemPosition = itemRenderBox.localToGlobal(Offset.zero);
            final itemTop = itemPosition.dy;
            final itemBottom = itemTop + itemRenderBox.size.height;

            if (itemBottom > viewportTop && itemTop <= viewportTop + 50) {
              return i;
            }
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _getDateLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (notificationDate == today) {
      return AppStrings.today.tr();
    } else if (notificationDate == yesterday) {
      return AppStrings.yesterday.tr();
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime);
    }
  }

  void _handleNotificationTap(NotificationEntity notification) {
    if (_lastTapTime != null && DateTime.now().difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastTapTime = DateTime.now();

    if (!notification.isRead) {
      _notificationBloc.add(MarkNotificationAsRead(notificationId: notification.id));
    }

    switch (notification.type) {
      case NotificationType.sessionAccepted:
      case NotificationType.sessionReminder:
      case NotificationType.sessionCompleted:
      case NotificationType.sessionSummaryAvailable:
        _navigateToSessionDetails(notification);
        break;

      case NotificationType.sessionExtensionPrompt:
        _navigateToExtendSession(notification);
        break;

      case NotificationType.refundIssued:
      case NotificationType.sessionExtensionApproved:
      case NotificationType.sessionExtensionDeclined:
        break;
    }
  }

  void _navigateToSessionDetails(NotificationEntity notification) {
    String? sessionId;

    final data = notification.data;
    if (data is SessionNotificationData) {
      sessionId = data.sessionId;
    }

    if (sessionId != null && sessionId.isNotEmpty) {
      context.push(AppRoutes.sessionDetailsRouteName, extra: SessionDetailsScreenParams(sessionId: sessionId));
    } else {
      SnackBarUtils.showError(context, AppStrings.unableToOpenNotification);
    }
  }

  void _navigateToExtendSession(NotificationEntity notification) {
    String? sessionId;
    double? totalFee;

    final data = notification.data;
    if (data is SessionNotificationData) {
      sessionId = data.sessionId;
      if (data.totalFee != null) {
        totalFee = double.tryParse(data.totalFee!);
      }
    }

    if (sessionId != null && sessionId.isNotEmpty && totalFee != null) {
      context.push(AppRoutes.extendSessionRouteName, extra: ExtendSessionScreenParams(sessionId: sessionId, totalFee: totalFee));
    } else {
      SnackBarUtils.showError(context, AppStrings.unableToOpenNotification);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userIdNotifier.dispose();
    _currentDateLabel.dispose();
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
              SnackBarUtils.showError(context, state.message);
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

      if (notifications.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _currentDateLabel.value = _getDateLabel(notifications.first.createdAt);
        });
      }

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
                ValueListenableBuilder<String>(
                  valueListenable: _currentDateLabel,
                  builder: (context, dateLabel, child) {
                    return Text(
                      dateLabel,
                      style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                    );
                  },
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

                  if (!_itemKeys.containsKey(index)) {
                    _itemKeys[index] = GlobalKey();
                  }

                  final notification = notifications[index];
                  return NotificationCard(key: _itemKeys[index], notification: notification, onTap: () => _handleNotificationTap(notification));
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
