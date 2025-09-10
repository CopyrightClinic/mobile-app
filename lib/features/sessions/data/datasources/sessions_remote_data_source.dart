import '../../../../core/network/api_service/api_service.dart';
import '../models/session_model.dart';
import 'sessions_mock_data_source.dart';

abstract class SessionsRemoteDataSource {
  Future<List<SessionModel>> getUserSessions();
  Future<List<SessionModel>> getUpcomingSessions();
  Future<List<SessionModel>> getCompletedSessions();
  Future<SessionModel> getSessionById(String sessionId);
  Future<String> cancelSession(String sessionId, String reason);
  Future<SessionModel> joinSession(String sessionId);
}

class SessionsRemoteDataSourceImpl implements SessionsRemoteDataSource {
  final ApiService apiService;

  SessionsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<SessionModel>> getUserSessions() async {
    // For now, return mock data. Replace with actual API call later.
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
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
    return 'Session cancelled successfully';
  }

  @override
  Future<SessionModel> joinSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allSessions = SessionsMockDataSource.getMockSessions();
    final session = allSessions.firstWhere((session) => session.id == sessionId);
    return session;
  }
}
