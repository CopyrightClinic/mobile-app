import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../../features/sessions/data/datasources/sessions_remote_data_source.dart';
import '../constants/pref_constants.dart';
import '../network/api_service/api_service.dart';
import '../network/dio_service.dart';
import '../network/endpoints/api_endpoints.dart';
import '../network/interceptors/api_interceptor.dart';
import '../utils/logger/logger.dart';
import '../utils/storage/shared_pref_service.dart';

/// Runs the "decline extension" call for the notification action button.
///
/// The decline button is handled without opening the app, which means this can
/// execute inside the flutter_local_notifications background isolate where the
/// service locator was never populated. When that happens the networking stack
/// is built on the spot so the same data source (and therefore the same auth
/// interceptor) is used in every state.
class SessionExtensionActionService {
  const SessionExtensionActionService._();

  static final SharedPrefService<List<dynamic>> _prefs = SharedPrefService<List<dynamic>>();

  static Future<bool> declineExtension(String sessionId) async {
    // Recorded before the request so the user stops seeing prompts even if the
    // call fails; the backend is the source of truth once it succeeds.
    await markDeclined(sessionId);

    try {
      await _ensureEnvLoaded();

      final dataSource = _resolveDataSource();
      final response = await dataSource.declineSessionExtension(sessionId: sessionId);

      Log.i('SessionExtensionActionService', '✅ Extension declined for session $sessionId: ${response.message}');
      return true;
    } catch (e, stackTrace) {
      Log.e('SessionExtensionActionService', '❌ Failed to decline extension for session $sessionId: $e');
      Log.e('SessionExtensionActionService', 'Stack trace: $stackTrace');
      return false;
    }
  }

  /// Local guard so a prompt that was already in flight when the user declined
  /// does not get displayed after the fact.
  static Future<bool> isDeclined(String sessionId) async {
    final declined = await _readDeclined();
    return declined.contains(sessionId);
  }

  static Future<void> markDeclined(String sessionId) async {
    final declined = await _readDeclined();
    if (declined.contains(sessionId)) return;

    declined.add(sessionId);
    // Keep the list bounded; only the most recent sessions can still prompt.
    final trimmed = declined.length > 20 ? declined.sublist(declined.length - 20) : declined;
    await _prefs.write(SharedPrefConstants.declinedExtensionSessionsKey, trimmed);
  }

  static Future<List<String>> _readDeclined() async {
    try {
      final stored = await _prefs.read(SharedPrefConstants.declinedExtensionSessionsKey);
      return stored?.map((e) => e.toString()).toList() ?? <String>[];
    } catch (e) {
      Log.w('SessionExtensionActionService', 'Could not read declined sessions: $e');
      return <String>[];
    }
  }

  static SessionsRemoteDataSource _resolveDataSource() {
    if (GetIt.I.isRegistered<SessionsRemoteDataSource>()) {
      return GetIt.I<SessionsRemoteDataSource>();
    }

    final dio = Dio(BaseOptions(baseUrl: ApiEndpoint.baseUrl));
    final dioService = DioService(dioClient: dio, interceptors: [ApiInterceptor()]);
    return SessionsRemoteDataSourceImpl(apiService: ApiService(dioService));
  }

  static Future<void> _ensureEnvLoaded() async {
    if (dotenv.isInitialized) return;

    await dotenv.load(
      fileName: const String.fromEnvironment('DOTENV_FILENAME', defaultValue: '.env'),
    );
  }
}
