import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  NotificationBloc({required this.getNotificationsUseCase, required this.markAllNotificationsAsReadUseCase}) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());

    final String timezone = await TimezoneHelper.getUserTimezone();
    final result = await getNotificationsUseCase(
      GetNotificationsParams(userId: event.userId, page: event.page, limit: event.limit, timezone: timezone),
    );

    result.fold((failure) => emit(NotificationError(failure.message ?? 'Unknown error')), (notificationResult) {
      emit(
        NotificationLoaded(
          notifications: notificationResult.notifications,
          total: notificationResult.total,
          currentPage: notificationResult.page,
          hasMore: notificationResult.hasMore,
        ),
      );
    });
  }

  Future<void> _onRefreshNotifications(RefreshNotifications event, Emitter<NotificationState> emit) async {
    final String timezone = await TimezoneHelper.getUserTimezone();
    final result = await getNotificationsUseCase(GetNotificationsParams(userId: event.userId, page: 1, limit: 20, timezone: timezone));

    result.fold((failure) => emit(NotificationError(failure.message ?? 'Unknown error')), (notificationResult) {
      emit(
        NotificationLoaded(
          notifications: notificationResult.notifications,
          total: notificationResult.total,
          currentPage: notificationResult.page,
          hasMore: notificationResult.hasMore,
        ),
      );
    });
  }

  Future<void> _onLoadMoreNotifications(LoadMoreNotifications event, Emitter<NotificationState> emit) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final String timezone = await TimezoneHelper.getUserTimezone();
    final result = await getNotificationsUseCase(
      GetNotificationsParams(userId: event.userId, page: currentState.currentPage + 1, limit: 20, timezone: timezone),
    );

    result.fold((failure) => emit(currentState.copyWith(isLoadingMore: false)), (notificationResult) {
      final updatedNotifications = List.of(currentState.notifications)..addAll(notificationResult.notifications);
      emit(
        NotificationLoaded(
          notifications: updatedNotifications,
          total: notificationResult.total,
          currentPage: notificationResult.page,
          hasMore: notificationResult.hasMore,
          isLoadingMore: false,
        ),
      );
    });
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsRead event, Emitter<NotificationState> emit) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;
    final originalNotifications = currentState.notifications;

    final optimisticNotifications = currentState.notifications.map((notification) => notification.copyWith(isRead: true)).toList();

    emit(currentState.copyWith(notifications: optimisticNotifications));

    final result = await markAllNotificationsAsReadUseCase();

    result.fold(
      (failure) {
        emit(currentState.copyWith(notifications: originalNotifications));
        emit(NotificationError(failure.message ?? 'Failed to mark all as read'));
        emit(currentState);
      },
      (markedCount) {
        if (state is! NotificationLoaded) return;
        final latestState = state as NotificationLoaded;
        emit(latestState.copyWith(notifications: optimisticNotifications));
      },
    );
  }
}
