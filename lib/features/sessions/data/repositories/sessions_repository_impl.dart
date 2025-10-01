import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_availability_entity.dart';
import '../../domain/entities/book_session_response_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_data_source.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource remoteDataSource;

  SessionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SessionEntity>>> getUserSessions({String? status, String? timezone}) async {
    try {
      final sessions = await remoteDataSource.getUserSessions(status: status, timezone: timezone);
      return Right(sessions.map((session) => session.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToFetchUserSessions}: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getUpcomingSessions() async {
    try {
      final sessions = await remoteDataSource.getUpcomingSessions();
      return Right(sessions.map((session) => session.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToFetchUpcomingSessions}: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getCompletedSessions() async {
    try {
      final sessions = await remoteDataSource.getCompletedSessions();
      return Right(sessions.map((session) => session.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToFetchCompletedSessions}: $e'));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> getSessionById(String sessionId) async {
    try {
      final session = await remoteDataSource.getSessionById(sessionId);
      return Right(session.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToFetchSession}: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> cancelSession(String sessionId, String reason) async {
    try {
      final message = await remoteDataSource.cancelSession(sessionId, reason);
      return Right(message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToCancelSessionGeneric}: $e'));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> joinSession(String sessionId) async {
    try {
      final session = await remoteDataSource.joinSession(sessionId);
      return Right(session.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToJoinSession}: $e'));
    }
  }

  @override
  Future<Either<Failure, SessionAvailabilityEntity>> getSessionAvailability(String timezone) async {
    try {
      final availability = await remoteDataSource.getSessionAvailability(timezone);
      return Right(availability.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToFetchSessionAvailability}: $e'));
    }
  }

  @override
  Future<Either<Failure, BookSessionResponseEntity>> bookSession({
    required String stripePaymentMethodId,
    required String date,
    required String startTime,
    required String endTime,
    required String summary,
    required String timezone,
  }) async {
    try {
      final response = await remoteDataSource.bookSession(
        stripePaymentMethodId: stripePaymentMethodId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        summary: summary,
        timezone: timezone,
      );
      return Right(response.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      String errorMessage = AppStrings.failedToBookSession;
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      }

      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(AppStrings.failedToBookSession));
    }
  }
}
