import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/session_entity.dart';

abstract class SessionsRepository {
  Future<Either<Failure, List<SessionEntity>>> getUserSessions();
  Future<Either<Failure, List<SessionEntity>>> getUpcomingSessions();
  Future<Either<Failure, List<SessionEntity>>> getCompletedSessions();
  Future<Either<Failure, SessionEntity>> getSessionById(String sessionId);
  Future<Either<Failure, String>> cancelSession(String sessionId, String reason);
  Future<Either<Failure, SessionEntity>> joinSession(String sessionId);
}
