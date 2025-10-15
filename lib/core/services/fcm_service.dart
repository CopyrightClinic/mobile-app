import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/models/device_token_model.dart';
import '../utils/logger/logger.dart';
import 'local_notification_service.dart';

class FCMService {
  final NotificationRemoteDataSource remoteDataSource;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  FCMService({required this.remoteDataSource});

  Future<void> initialize() async {
    try {
      await _requestPermission();
      await _localNotificationService.initialize();
      await _registerDeviceToken();
      _setupForegroundNotificationHandling();
      _setupTokenRefreshListener();
    } catch (e) {
      Log.e(runtimeType, 'Error initializing FCM: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Log.i(runtimeType, 'User granted FCM permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        Log.i(runtimeType, 'User granted provisional FCM permission');
      } else {
        Log.w(runtimeType, 'User declined FCM permission');
      }
    } catch (e) {
      Log.e(runtimeType, 'Error requesting FCM permission: $e');
    }
  }

  Future<void> _registerDeviceToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        Log.i(runtimeType, 'FCM Token: $token');
        await registerToken(token);
      }
    } catch (e) {
      Log.e(runtimeType, 'Error getting FCM token: $e');
    }
  }

  Future<void> registerToken(String token) async {
    try {
      final request = RegisterDeviceTokenRequestModel(token: token);
      await remoteDataSource.registerDeviceToken(request);
      Log.i(runtimeType, 'Device token registered successfully');
    } catch (e) {
      Log.e(runtimeType, 'Error registering device token: $e');
      _scheduleTokenRetry(token);
    }
  }

  void _scheduleTokenRetry(String token) {
    Future.delayed(const Duration(seconds: 30), () async {
      Log.i(runtimeType, 'Retrying device token registration');
      try {
        final request = RegisterDeviceTokenRequestModel(token: token);
        await remoteDataSource.registerDeviceToken(request);
        Log.i(runtimeType, 'Device token registered successfully on retry');
      } catch (e) {
        Log.e(runtimeType, 'Error registering device token on retry: $e');
      }
    });
  }

  void _setupForegroundNotificationHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.i(runtimeType, 'Got a message whilst in the foreground!');
      Log.i(runtimeType, 'Message data: ${message.data}');

      if (message.notification != null) {
        Log.i(runtimeType, 'Message notification: ${message.notification?.title} - ${message.notification?.body}');

        _localNotificationService.showNotification(message);
      }
    });
  }

  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      Log.i(runtimeType, 'FCM token refreshed: $newToken');
      registerToken(newToken);
    });
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      Log.e(runtimeType, 'Error getting FCM token: $e');
      return null;
    }
  }
}
