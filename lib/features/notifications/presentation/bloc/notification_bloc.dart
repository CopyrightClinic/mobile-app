import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  NotificationBloc({required this.getNotificationsUseCase, required this.markNotificationAsReadUseCase}) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());

    final result = await getNotificationsUseCase(GetNotificationsParams(userId: event.userId, page: event.page, limit: event.limit));

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
    final result = await getNotificationsUseCase(GetNotificationsParams(userId: event.userId, page: 1, limit: 20));

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

    final result = await getNotificationsUseCase(GetNotificationsParams(userId: event.userId, page: currentState.currentPage + 1, limit: 20));

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

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;
    final originalNotifications = currentState.notifications;

    final optimisticNotifications =
        currentState.notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

    emit(currentState.copyWith(notifications: optimisticNotifications));

    final result = await markNotificationAsReadUseCase(MarkNotificationAsReadParams(notificationId: event.notificationId));

    result.fold(
      (failure) {
        emit(currentState.copyWith(notifications: originalNotifications));
      },
      (updatedNotification) {
        if (state is! NotificationLoaded) return;
        final latestState = state as NotificationLoaded;

        final updatedNotifications =
            latestState.notifications.map((notification) {
              if (notification.id == updatedNotification.id) {
                return updatedNotification;
              }
              return notification;
            }).toList();

        emit(latestState.copyWith(notifications: updatedNotifications));
      },
    );
  }
}
