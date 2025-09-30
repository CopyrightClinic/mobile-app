import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/session_model.dart';
import '../models/session_availability_model.dart';
import '../models/book_session_request_model.dart';
import '../models/book_session_response_model.dart';
import 'sessions_mock_data_source.dart';

abstract class SessionsRemoteDataSource {
  Future<List<SessionModel>> getUserSessions();
  Future<List<SessionModel>> getUpcomingSessions();
  Future<List<SessionModel>> getCompletedSessions();
  Future<SessionModel> getSessionById(String sessionId);
  Future<String> cancelSession(String sessionId, String reason);
  Future<SessionModel> joinSession(String sessionId);
  Future<SessionAvailabilityModel> getSessionAvailability(String timezone);
  Future<BookSessionResponseModel> bookSession({
    required String stripePaymentMethodId,
    required String date,
    required String startTime,
    required String endTime,
    required String summary,
    required String timezone,
  });
}

class SessionsRemoteDataSourceImpl implements SessionsRemoteDataSource {
  final ApiService apiService;

  SessionsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<SessionModel>> getUserSessions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SessionsMockDataSource.getMockSessions();
  }

  @override
  Future<List<SessionModel>> getUpcomingSessions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allSessions = SessionsMockDataSource.getMockSessions();
    return allSessions.where((session) => session.status == 'upcoming').toList();
  }

  @override
  Future<List<SessionModel>> getCompletedSessions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allSessions = SessionsMockDataSource.getMockSessions();
    return allSessions.where((session) => session.status == 'completed').toList();
  }

  @override
  Future<SessionModel> getSessionById(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allSessions = SessionsMockDataSource.getMockSessions();
    final session = allSessions.firstWhere((session) => session.id == sessionId);
    return session;
  }

  @override
  Future<String> cancelSession(String sessionId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AppStrings.sessionCancelledSuccessfully;
  }

  @override
  Future<SessionModel> joinSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allSessions = SessionsMockDataSource.getMockSessions();
    final session = allSessions.firstWhere((session) => session.id == sessionId);
    return session;
  }

  @override
  Future<SessionAvailabilityModel> getSessionAvailability(String timezone) async {
    return await apiService.getData<SessionAvailabilityModel>(
      endpoint: '/sessions-availability',
      headers: {'Timezone': timezone},
      converter: (json) => SessionAvailabilityModel.fromJson(json),
    );
  }

  @override
  Future<BookSessionResponseModel> bookSession({
    required String stripePaymentMethodId,
    required String date,
    required String startTime,
    required String endTime,
    required String summary,
    required String timezone,
  }) async {
    final request = BookSessionRequestModel(
      stripePaymentMethodId: stripePaymentMethodId,
      date: date,
      slot: BookSessionSlotModel(start: startTime, end: endTime),
      summary: summary,
    );
    return await apiService.postData<BookSessionResponseModel>(
      endpoint: '/session-requests/book-session',
      headers: {'Timezone': timezone},
      data: request.toJson(),
      converter: (json) => BookSessionResponseModel.fromJson(json.data),
    );
  }
}
