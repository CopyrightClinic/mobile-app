import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/models/device_token_model.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_event.dart';
import '../utils/logger/logger.dart';
import '../utils/storage/user_storage.dart';
import 'local_notification_service.dart';
import 'notification_type_mapper.dart';

class FCMService {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationBloc notificationBloc;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  FCMService({required this.remoteDataSource, required this.notificationBloc});

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
      Log.i(runtimeType, '📱 ========================================');
      Log.i(runtimeType, '📱 FOREGROUND NOTIFICATION RECEIVED');
      Log.i(runtimeType, '📱 ========================================');
      Log.i(runtimeType, '📱 Message ID: ${message.messageId}');
      Log.i(runtimeType, '📱 Notification Title: ${message.notification?.title}');
      Log.i(runtimeType, '📱 Notification Body: ${message.notification?.body}');
      Log.i(runtimeType, '📱 Data Payload: ${message.data}');
      Log.i(runtimeType, '📱 ========================================');

      if (message.notification != null) {
        _processNotification(message);
        _localNotificationService.showNotification(message);
      } else {
        Log.w(runtimeType, '⚠️ No notification payload, skipping display');
      }
    });
  }

  void _processNotification(RemoteMessage message) {
    try {
      final data = message.data;
      final type = data['type'] as String?;

      Log.i(runtimeType, '🔍 Processing notification...');
      Log.i(runtimeType, '🔍 Type from payload: $type');

      if (type == null) {
        Log.w(runtimeType, '⚠️ Notification type is null, cannot process');
        return;
      }

      final shouldCreateInApp = NotificationTypeMapper.shouldCreateInAppNotification(type);

      if (shouldCreateInApp) {
        final inAppType = NotificationTypeMapper.mapFCMToInApp(type);
        Log.i(runtimeType, '✅ Type $type → In-app: $inAppType (will sync with backend)');
        _refreshInAppNotifications();
      } else {
        Log.i(runtimeType, '📲 Type $type is push-only (no in-app notification)');
      }
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Error processing notification: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  Future<void> _refreshInAppNotifications() async {
    try {
      final user = await UserStorage.getUser();
      if (user != null) {
        notificationBloc.add(RefreshNotifications(userId: user.id));
      }
    } catch (e) {
      Log.e(runtimeType, 'Error refreshing in-app notifications: $e');
    }
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
