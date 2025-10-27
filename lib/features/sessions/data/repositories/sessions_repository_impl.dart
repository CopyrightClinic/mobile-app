import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_details_entity.dart';
import '../../domain/entities/submit_feedback_response_entity.dart';
import '../../domain/entities/cancel_session_response_entity.dart';
import '../../domain/entities/session_availability_entity.dart';
import '../../domain/entities/book_session_response_entity.dart';
import '../../domain/entities/paginated_sessions_entity.dart';
import '../../domain/entities/unlock_summary_response_entity.dart';
import '../../domain/entities/extend_session_response_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_data_source.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource remoteDataSource;

  SessionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedSessionsEntity>> getUserSessions({String? status, String? timezone, int? page, int? limit}) async {
    try {
      final paginatedSessions = await remoteDataSource.getUserSessions(status: status, timezone: timezone, page: page, limit: limit);
      return Right(paginatedSessions.toEntity());
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
  Future<Either<Failure, SessionDetailsEntity>> getSessionDetails({required String sessionId, String? timezone}) async {
    try {
      final sessionDetails = await remoteDataSource.getSessionDetails(sessionId: sessionId, timezone: timezone);
      return Right(sessionDetails.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToFetchSession}: $e'));
    }
  }

  @override
  Future<Either<Failure, SubmitFeedbackResponseEntity>> submitSessionFeedback({
    required String sessionId,
    required double rating,
    String? review,
  }) async {
    try {
      final response = await remoteDataSource.submitSessionFeedback(sessionId: sessionId, rating: rating, review: review);
      return Right(response.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToSubmitFeedback}: $e'));
    }
  }

  @override
  Future<Either<Failure, CancelSessionResponseEntity>> cancelSession(String sessionId, String reason) async {
    try {
      final response = await remoteDataSource.cancelSession(sessionId, reason);
      return Right(response.toEntity());
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

  @override
  Future<Either<Failure, UnlockSummaryResponseEntity>> unlockSessionSummary({
    required String sessionId,
    required String paymentMethodId,
    required double summaryFee,
  }) async {
    try {
      final response = await remoteDataSource.unlockSessionSummary(sessionId: sessionId, paymentMethodId: paymentMethodId, summaryFee: summaryFee);
      return Right(response.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      String errorMessage = AppStrings.failedToLoadPaymentMethods;
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToUnlockSessionSummary}: $e'));
    }
  }

  @override
  Future<Either<Failure, ExtendSessionResponseEntity>> extendSession({required String sessionId, required String paymentMethodId}) async {
    try {
      final response = await remoteDataSource.extendSession(sessionId: sessionId, paymentMethodId: paymentMethodId);
      return Right(response.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      String errorMessage = AppStrings.sessionExtendError;
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      }
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      return Left(ServerFailure(AppStrings.sessionExtendError));
    }
  }
}
