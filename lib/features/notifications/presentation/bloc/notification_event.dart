import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;
  final int page;
  final int limit;

  const LoadNotifications({required this.userId, this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [userId, page, limit];
}

class RefreshNotifications extends NotificationEvent {
  final String userId;

  const RefreshNotifications({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadMoreNotifications extends NotificationEvent {
  final String userId;

  const LoadMoreNotifications({required this.userId});

  @override
  List<Object> get props => [userId];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}
