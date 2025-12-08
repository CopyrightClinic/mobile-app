import 'dart:async';
import 'package:flutter/services.dart';
import '../constants/app_strings.dart';
import '../network/api_service/api_service.dart';
import '../utils/enumns/ui/zoom_meeting_status.dart';

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
        return _cachedJwt!;
      }

      final response = await _apiService.getData<Map<String, dynamic>>(endpoint: '/zoom/native-jwt', converter: (json) => json);

      if (response['jwt'] == null || response['jwt'].toString().isEmpty) {
        throw Exception('JWT not found in response');
      }

      _cachedJwt = response['jwt'].toString();
      _jwtFetchTime = DateTime.now();

      return _cachedJwt!;
    } catch (e) {
      throw Exception('${AppStrings.zoomErrorFetchJwt}: $e');
    }
  }

  Future<Map<String, dynamic>> initZoom({bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh) {
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
        }
        return resultMap;
      }

      _isInitialized = true;
      return {'success': true, 'message': 'Initialized'};
    } on PlatformException catch (e) {
      if (e.code == 'JWT_INVALID' && !forceRefresh) {
        _cachedJwt = null;
        _jwtFetchTime = null;
        _isInitializing = false;
        return await initZoom(forceRefresh: true);
      }

      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Map<String, dynamic>> initZoomWithJwt(String jwt) async {
    if (_isInitialized) {
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
        }
        return resultMap;
      }

      _isInitialized = true;
      return {'success': true, 'message': 'Initialized'};
    } on PlatformException {
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Map<String, dynamic>> joinMeeting({required String meetingNumber, required String passcode, required String displayName}) async {
    if (!_isInitialized) {
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
      if (e.code == 'NOT_INITIALIZED') {
        _isInitialized = false;
        await initZoom();
        return await joinMeeting(meetingNumber: meetingNumber, passcode: passcode, displayName: displayName);
      }

      rethrow;
    } catch (e) {
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
      rethrow;
    }
  }

  Future<String?> getSdkVersion() async {
    try {
      final version = await _methodChannel.invokeMethod('getSdkVersion');
      return version?.toString();
    } catch (e) {
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

        onStatusChanged(status, message);
      },
      onError: (error) {
        // Silently handle error
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
