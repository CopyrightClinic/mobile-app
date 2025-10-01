import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/utils/enumns/api/sessions_enums.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/session_model.dart';
import '../models/session_details_model.dart';
import '../models/session_availability_model.dart';
import '../models/book_session_request_model.dart';
import '../models/book_session_response_model.dart';
import 'sessions_mock_data_source.dart';

abstract class SessionsRemoteDataSource {
  Future<List<SessionModel>> getUserSessions({String? status, String? timezone});
  Future<List<SessionModel>> getUpcomingSessions();
  Future<List<SessionModel>> getCompletedSessions();
  Future<SessionModel> getSessionById(String sessionId);
  Future<SessionDetailsModel> getSessionDetails({required String sessionId, String? timezone});
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
  Future<List<SessionModel>> getUserSessions({String? status, String? timezone}) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null) queryParams['status'] = status;

    final Map<String, dynamic> headers = {};
    if (timezone != null) headers['timezone'] = timezone;

    return await apiService.getCollectionData<SessionModel>(
      endpoint: ApiEndpoint.sessions(SessionsEndpoint.USER_SESSIONS),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      headers: headers.isNotEmpty ? headers : null,
      converter: (json) => SessionModel.fromJson(json),
    );
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
  Future<SessionDetailsModel> getSessionDetails({required String sessionId, String? timezone}) async {
    final Map<String, dynamic> queryParams = {'sessionId': sessionId};
    final Map<String, dynamic> headers = {};
    if (timezone != null) headers['timezone'] = timezone;

    return await apiService.getData<SessionDetailsModel>(
      endpoint: ApiEndpoint.sessions(SessionsEndpoint.SESSION_DETAILS),
      queryParams: queryParams,
      headers: headers.isNotEmpty ? headers : null,
      converter: (json) => SessionDetailsModel.fromJson(json),
    );
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
      endpoint: ApiEndpoint.sessions(SessionsEndpoint.SESSIONS_AVAILABILITY),
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
      endpoint: ApiEndpoint.sessions(SessionsEndpoint.BOOK_SESSION),
      headers: {'Timezone': timezone},
      data: request.toJson(),
      converter: (json) => BookSessionResponseModel.fromJson(json.data),
    );
  }
}
