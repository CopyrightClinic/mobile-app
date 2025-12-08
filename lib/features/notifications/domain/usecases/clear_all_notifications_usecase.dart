import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class ClearAllNotificationsUseCase {
  final NotificationRepository repository;

  ClearAllNotificationsUseCase({required this.repository});

  Future<Either<Failure, int>> call() async {
    return await repository.clearAllNotifications();
  }
}

