import 'dart:async';
import 'package:flutter/services.dart';
import '../constants/app_strings.dart';
import '../network/api_service/api_service.dart';
import '../utils/enumns/ui/zoom_meeting_status.dart';
import '../utils/logger/logger.dart';

class ZoomService {
  static const MethodChannel _methodChannel = MethodChannel('com.example.zoom');
  static const EventChannel _eventChannel = EventChannel('com.example.zoom/events');

  final ApiService _apiService;

  Stream<Map<dynamic, dynamic>>? _eventStream;
  StreamSubscription<Map<dynamic, dynamic>>? _eventSubscription;

  bool _isInitialized = false;
  bool _isInitializing = false;
  String? _cachedJwt;
  DateTime? _jwtFetchTime;

  static const Duration _jwtCacheDuration = Duration(minutes: 50);

  ZoomService(this._apiService);

  bool get isInitialized => _isInitialized;

  Stream<Map<dynamic, dynamic>> get eventStream {
    _eventStream ??= _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<dynamic, dynamic>.from(event);
      }
      return <dynamic, dynamic>{};
    });
    return _eventStream!;
  }

  Future<String> _fetchJwtFromBackend() async {
    try {
      if (_cachedJwt != null && _jwtFetchTime != null && DateTime.now().difference(_jwtFetchTime!) < _jwtCacheDuration) {
        Log.d('ZoomService', 'Using cached JWT');
        return _cachedJwt!;
      }

      Log.d('ZoomService', 'Fetching fresh JWT from backend');

      final response = await _apiService.getData<Map<String, dynamic>>(endpoint: '/zoom/native-jwt', converter: (json) => json);

      if (response['jwt'] == null || response['jwt'].toString().isEmpty) {
        throw Exception('JWT not found in response');
      }

      _cachedJwt = response['jwt'].toString();
      _jwtFetchTime = DateTime.now();

      Log.d('ZoomService', 'JWT fetched successfully');
      return _cachedJwt!;
    } catch (e) {
      Log.e('ZoomService', 'Failed to fetch JWT: $e');
      throw Exception('${AppStrings.zoomErrorFetchJwt}: $e');
    }
  }

  Future<Map<String, dynamic>> initZoom({bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh) {
      Log.d('ZoomService', 'Already initialized');
      return {'success': true, 'message': 'Already initialized'};
    }

    if (_isInitializing) {
      throw Exception(AppStrings.zoomErrorAlreadyInitializing);
    }

    _isInitializing = true;

    try {
      if (forceRefresh) {
        _cachedJwt = null;
        _jwtFetchTime = null;
      }

      final jwt = await _fetchJwtFromBackend();

      final result = await _methodChannel.invokeMethod('initZoom', {'jwt': jwt});

      if (result is Map) {
        final resultMap = Map<String, dynamic>.from(result);
        if (resultMap['success'] == true) {
          _isInitialized = true;
          Log.i('ZoomService', 'Zoom SDK initialized successfully');
        }
        return resultMap;
      }

      _isInitialized = true;
      return {'success': true, 'message': 'Initialized'};
    } on PlatformException catch (e) {
      Log.e('ZoomService', 'Platform exception during init: ${e.code} - ${e.message}');

      if (e.code == 'JWT_INVALID' && !forceRefresh) {
        Log.d('ZoomService', 'JWT invalid, retrying with fresh token');
        _cachedJwt = null;
        _jwtFetchTime = null;
        _isInitializing = false;
        return await initZoom(forceRefresh: true);
      }

      rethrow;
    } catch (e) {
      Log.e('ZoomService', 'Error during init: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Map<String, dynamic>> initZoomWithJwt(String jwt) async {
    if (_isInitialized) {
      Log.d('ZoomService', 'Already initialized, reinitializing with new JWT');
      _isInitialized = false;
    }

    if (_isInitializing) {
      throw Exception(AppStrings.zoomErrorAlreadyInitializing);
    }

    _isInitializing = true;

    try {
      final result = await _methodChannel.invokeMethod('initZoom', {'jwt': jwt});

      if (result is Map) {
        final resultMap = Map<String, dynamic>.from(result);
        if (resultMap['success'] == true) {
          _isInitialized = true;
          Log.i('ZoomService', 'Zoom SDK initialized successfully with provided JWT');
        }
        return resultMap;
      }

      _isInitialized = true;
      return {'success': true, 'message': 'Initialized'};
    } on PlatformException catch (e) {
      Log.e('ZoomService', 'Platform exception during init with JWT: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      Log.e('ZoomService', 'Error during init with JWT: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Map<String, dynamic>> joinMeeting({required String meetingNumber, required String passcode, required String displayName}) async {
    if (!_isInitialized) {
      Log.d('ZoomService', 'Not initialized, initializing first');
      await initZoom();
    }

    try {
      final result = await _methodChannel.invokeMethod('joinMeeting', {
        'meetingNumber': meetingNumber,
        'passcode': passcode,
        'displayName': displayName,
      });

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }

      return {'success': true, 'message': 'Join request sent'};
    } on PlatformException catch (e) {
      Log.e('ZoomService', 'Platform exception during join: ${e.code} - ${e.message}');

      if (e.code == 'NOT_INITIALIZED') {
        Log.d('ZoomService', 'SDK not initialized, reinitializing');
        _isInitialized = false;
        await initZoom();
        return await joinMeeting(meetingNumber: meetingNumber, passcode: passcode, displayName: displayName);
      }

      rethrow;
    } catch (e) {
      Log.e('ZoomService', 'Error during join: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> leaveMeeting() async {
    try {
      final result = await _methodChannel.invokeMethod('leaveMeeting');

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }

      return {'success': true, 'message': 'Left meeting'};
    } catch (e) {
      Log.e('ZoomService', 'Error during leave: $e');
      rethrow;
    }
  }

  Future<String?> getSdkVersion() async {
    try {
      final version = await _methodChannel.invokeMethod('getSdkVersion');
      return version?.toString();
    } catch (e) {
      Log.e('ZoomService', 'Error getting SDK version: $e');
      return null;
    }
  }

  void listenToMeetingEvents({required Function(ZoomMeetingStatus status, String? message) onStatusChanged}) {
    _eventSubscription?.cancel();

    _eventSubscription = eventStream.listen(
      (event) {
        final statusString = event['status']?.toString() ?? 'UNKNOWN';
        final status = ZoomMeetingStatus.fromString(statusString);
        final message = event['message']?.toString();

        Log.d('ZoomService', 'Meeting status: $statusString, message: $message');
        onStatusChanged(status, message);
      },
      onError: (error) {
        Log.e('ZoomService', 'Event stream error: $error');
      },
    );
  }

  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _cachedJwt = null;
    _jwtFetchTime = null;
  }
}
