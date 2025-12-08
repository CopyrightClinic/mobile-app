import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsParams extends Equatable {
  final String userId;
  final int page;
  final int limit;
  final String? timezone;

  const GetNotificationsParams({required this.userId, this.page = 1, this.limit = 20, this.timezone});

  @override
  List<Object?> get props => [userId, page, limit, timezone];
}

class GetNotificationsUseCase implements UseCase<NotificationListResult, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationListResult>> call(GetNotificationsParams params) async {
    return await repository.getNotifications(userId: params.userId, page: params.page, limit: params.limit, timezone: params.timezone);
  }
}
