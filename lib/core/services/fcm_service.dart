import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/models/device_token_model.dart';
import '../utils/logger/logger.dart';

class FCMService {
  final NotificationRemoteDataSource remoteDataSource;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FCMService({required this.remoteDataSource});

  Future<void> initialize() async {
    try {
      await _requestPermission();
      await _registerDeviceToken();
      _setupForegroundNotificationHandling();
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
    }
  }

  void _setupForegroundNotificationHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Log.i(runtimeType, 'Got a message whilst in the foreground!');
      Log.i(runtimeType, 'Message data: ${message.data}');

      if (message.notification != null) {
        Log.i(runtimeType, 'Message notification: ${message.notification?.title} - ${message.notification?.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.i(runtimeType, 'Message clicked!');
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
