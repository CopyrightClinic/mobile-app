import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationBloc({required this.getNotificationsUseCase}) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());

    final result = await getNotificationsUseCase(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message ?? 'Unknown error')), (notifications) {
      emit(NotificationLoaded(notifications: notifications));
    });
  }

  Future<void> _onRefreshNotifications(RefreshNotifications event, Emitter<NotificationState> emit) async {
    final result = await getNotificationsUseCase(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message ?? 'Unknown error')), (notifications) {
      emit(NotificationLoaded(notifications: notifications));
    });
  }
}
