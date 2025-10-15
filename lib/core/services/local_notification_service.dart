import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';
import 'push_notification_handler.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings, onDidReceiveNotificationResponse: _onNotificationTapped);

    _isInitialized = true;
    Log.i(runtimeType, 'Local notifications initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final message = RemoteMessage(data: Map<String, dynamic>.from(data));
        PushNotificationHandler().handleNotificationTap(message);
      } catch (e) {
        Log.e(runtimeType, 'Error handling notification tap: $e');
      }
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notification = message.notification;
      final data = message.data;

      if (notification == null) {
        Log.w(runtimeType, 'Notification payload is null');
        return;
      }

      final notificationType = _getNotificationType(data);
      final androidDetails = _getAndroidNotificationDetails(notificationType);
      final iosDetails = _getIOSNotificationDetails(notificationType);

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title ?? 'Copyright Clinic',
        notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(data),
      );

      Log.i(runtimeType, 'Local notification shown: ${notification.title}');
    } catch (e) {
      Log.e(runtimeType, 'Error showing local notification: $e');
    }
  }

  PushNotificationType? _getNotificationType(Map<String, dynamic> data) {
    try {
      final typeString = data['type'] as String?;
      if (typeString != null) {
        return PushNotificationType.fromString(typeString);
      }
    } catch (e) {
      Log.w(runtimeType, 'Could not parse notification type: $e');
    }
    return null;
  }

  AndroidNotificationDetails _getAndroidNotificationDetails(PushNotificationType? type) {
    final channelId = _getChannelId(type);
    final channelName = _getChannelName(type);
    final importance = _getImportance(type);
    final priority = _getPriority(type);

    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Copyright Clinic notifications',
      importance: importance,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  DarwinNotificationDetails _getIOSNotificationDetails(PushNotificationType? type) {
    return DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, interruptionLevel: _getIOSInterruptionLevel(type));
  }

  String _getChannelId(PushNotificationType? type) {
    if (type == null) return 'default_channel';

    if (type.isSessionRelated) {
      return 'session_channel';
    } else if (type.isPaymentRelated) {
      return 'payment_channel';
    }
    return 'default_channel';
  }

  String _getChannelName(PushNotificationType? type) {
    if (type == null) return 'Default Notifications';

    if (type.isSessionRelated) {
      return 'Session Notifications';
    } else if (type.isPaymentRelated) {
      return 'Payment Notifications';
    }
    return 'Default Notifications';
  }

  Importance _getImportance(PushNotificationType? type) {
    if (type == null) return Importance.defaultImportance;

    switch (type) {
      case PushNotificationType.joinSessionActivated:
      case PushNotificationType.sessionReminderPreStart:
      case PushNotificationType.failedPayment:
        return Importance.high;
      case PushNotificationType.sessionCancelledByAttorney:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(PushNotificationType? type) {
    if (type == null) return Priority.defaultPriority;

    switch (type) {
      case PushNotificationType.joinSessionActivated:
      case PushNotificationType.sessionReminderPreStart:
      case PushNotificationType.failedPayment:
        return Priority.high;
      case PushNotificationType.sessionCancelledByAttorney:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  InterruptionLevel _getIOSInterruptionLevel(PushNotificationType? type) {
    if (type == null) return InterruptionLevel.active;

    switch (type) {
      case PushNotificationType.joinSessionActivated:
      case PushNotificationType.sessionReminderPreStart:
        return InterruptionLevel.timeSensitive;
      case PushNotificationType.failedPayment:
      case PushNotificationType.sessionCancelledByAttorney:
        return InterruptionLevel.timeSensitive;
      default:
        return InterruptionLevel.active;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<int?> getActiveNotificationCount() async {
    final activeNotifications = await _flutterLocalNotificationsPlugin.getActiveNotifications();
    return activeNotifications.length;
  }
}
