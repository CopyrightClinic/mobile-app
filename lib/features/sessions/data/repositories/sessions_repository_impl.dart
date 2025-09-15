import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_availability_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_data_source.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource remoteDataSource;

  SessionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SessionEntity>>> getUserSessions() async {
    try {
      final sessions = await remoteDataSource.getUserSessions();
      return Right(sessions.map((session) => session.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user sessions: $e'));
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
      return Left(ServerFailure('Failed to fetch upcoming sessions: $e'));
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
      return Left(ServerFailure('Failed to fetch completed sessions: $e'));
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
      return Left(ServerFailure('Failed to fetch session: $e'));
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
      return Left(ServerFailure('Failed to cancel session: $e'));
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
      return Left(ServerFailure('Failed to join session: $e'));
    }
  }

  @override
  Future<Either<Failure, SessionAvailabilityEntity>> getSessionAvailability(String timezone) async {
    try {
      final availability = await remoteDataSource.getSessionAvailability(timezone);
      return Right(availability.toEntity());
    } on CustomException catch (e, stackTrace) {
      Log.e(SessionsRepositoryImpl, e.message, stackTrace);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e(SessionsRepositoryImpl, 'Failed to fetch session availability: $e', stackTrace);
      return Left(ServerFailure('Failed to fetch session availability: $e'));
    }
  }
}
