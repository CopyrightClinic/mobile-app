import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int total;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.notifications,
    required this.total,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  NotificationLoaded copyWith({List<NotificationEntity>? notifications, int? total, int? currentPage, bool? hasMore, bool? isLoadingMore}) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [notifications, total, currentPage, hasMore, isLoadingMore];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}
