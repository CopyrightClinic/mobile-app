import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationListResult>> getNotifications({required String userId, int page = 1, int limit = 20}) async {
    try {
      final response = await remoteDataSource.getNotifications(userId: userId, page: page, limit: limit);

      return Right(
        NotificationListResult(
          notifications: response.data.map((model) => model.toEntity()).toList(),
          total: response.total,
          page: response.page,
          limit: response.limit,
        ),
      );
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(String notificationId) async {
    try {
      final notification = await remoteDataSource.markAsRead(notificationId);
      return Right(notification.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
