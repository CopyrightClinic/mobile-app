import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

class NotificationListResult {
  final List<NotificationEntity> notifications;
  final int total;
  final int page;
  final int limit;

  const NotificationListResult({required this.notifications, required this.total, required this.page, required this.limit});

  bool get hasMore => page * limit < total;
}

abstract class NotificationRepository {
  Future<Either<Failure, NotificationListResult>> getNotifications({required String userId, int page = 1, int limit = 20, String? timezone});

  Future<Either<Failure, int>> markAllAsRead();

  Future<Either<Failure, void>> markNotificationAsRead({required String notificationId});
}
