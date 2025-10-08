import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/session_entity.dart';
import '../entities/session_details_entity.dart';
import '../entities/submit_feedback_response_entity.dart';
import '../entities/session_availability_entity.dart';
import '../entities/book_session_response_entity.dart';
import '../entities/paginated_sessions_entity.dart';

abstract class SessionsRepository {
  Future<Either<Failure, PaginatedSessionsEntity>> getUserSessions({String? status, String? timezone, int? page, int? limit});
  Future<Either<Failure, List<SessionEntity>>> getUpcomingSessions();
  Future<Either<Failure, List<SessionEntity>>> getCompletedSessions();
  Future<Either<Failure, SessionEntity>> getSessionById(String sessionId);
  Future<Either<Failure, SessionDetailsEntity>> getSessionDetails({required String sessionId, String? timezone});
  Future<Either<Failure, SubmitFeedbackResponseEntity>> submitSessionFeedback({required String sessionId, required double rating, String? review});
  Future<Either<Failure, String>> cancelSession(String sessionId, String reason);
  Future<Either<Failure, SessionEntity>> joinSession(String sessionId);
  Future<Either<Failure, SessionAvailabilityEntity>> getSessionAvailability(String timezone);
  Future<Either<Failure, BookSessionResponseEntity>> bookSession({
    required String stripePaymentMethodId,
    required String date,
    required String startTime,
    required String endTime,
    required String summary,
    required String timezone,
  });
}
