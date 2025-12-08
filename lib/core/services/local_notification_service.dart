import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';
import '../utils/session_datetime_utils.dart';
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
    Log.i(runtimeType, '👆 ========================================');
    Log.i(runtimeType, '👆 LOCAL NOTIFICATION TAPPED');
    Log.i(runtimeType, '👆 ========================================');
    Log.i(runtimeType, '👆 Response ID: ${response.id}');
    Log.i(runtimeType, '👆 Action ID: ${response.actionId}');

    if (response.payload != null) {
      try {
        Log.i(runtimeType, '👆 Payload: ${response.payload}');
        final data = jsonDecode(response.payload!);
        Log.i(runtimeType, '👆 Decoded Data: $data');

        final message = RemoteMessage(data: Map<String, dynamic>.from(data));
        Log.i(runtimeType, '👆 Forwarding to PushNotificationHandler...');
        PushNotificationHandler().handleNotificationTap(message);
      } catch (e, stackTrace) {
        Log.e(runtimeType, '❌ Error handling local notification tap: $e');
        Log.e(runtimeType, 'Stack trace: $stackTrace');
      }
    } else {
      Log.w(runtimeType, '⚠️ No payload in notification response');
    }
    Log.i(runtimeType, '👆 ========================================');
  }

  Future<void> showNotification(RemoteMessage message) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notification = message.notification;
      final data = message.data;

      Log.i(runtimeType, '🔔 ========================================');
      Log.i(runtimeType, '🔔 SHOWING LOCAL NOTIFICATION');
      Log.i(runtimeType, '🔔 ========================================');

      if (notification == null) {
        Log.w(runtimeType, '⚠️ Notification payload is null, cannot show');
        return;
      }

      final notificationType = _getNotificationType(data);
      Log.i(runtimeType, '🔔 Notification Type: ${notificationType?.toApiString() ?? "Unknown"}');
      Log.i(runtimeType, '🔔 Title: ${notification.title}');
      Log.i(runtimeType, '🔔 Body (Original): ${notification.body}');

      final localizedBody = await _getLocalizedNotificationBody(notification.body, data, notificationType);
      Log.i(runtimeType, '🔔 Body (Localized): $localizedBody');

      final androidDetails = _getAndroidNotificationDetails(notificationType);
      final iosDetails = _getIOSNotificationDetails(notificationType);

      Log.i(runtimeType, '🔔 Android Channel: ${androidDetails.channelId}');
      Log.i(runtimeType, '🔔 Android Priority: ${androidDetails.priority}');
      Log.i(runtimeType, '🔔 iOS Interruption Level: ${iosDetails.interruptionLevel}');

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title ?? 'Copyright Clinic',
        localizedBody,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(data),
      );

      Log.i(runtimeType, '✅ Local notification displayed successfully');
      Log.i(runtimeType, '🔔 ========================================');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Error showing local notification: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
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
      case PushNotificationType.sessionReminder:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(PushNotificationType? type) {
    if (type == null) return Priority.defaultPriority;

    switch (type) {
      case PushNotificationType.sessionReminder:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  InterruptionLevel _getIOSInterruptionLevel(PushNotificationType? type) {
    if (type == null) return InterruptionLevel.active;

    switch (type) {
      case PushNotificationType.sessionReminder:
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

  Future<String> _getLocalizedNotificationBody(String? originalBody, Map<String, dynamic> data, PushNotificationType? notificationType) async {
    if (originalBody == null || originalBody.isEmpty) {
      return '';
    }

    if (notificationType != PushNotificationType.sessionAccepted) {
      Log.i(runtimeType, '⚠️ Notification type is not SESSION_ACCEPTED, skipping datetime conversion');
      return originalBody;
    }

    try {
      final scheduledDate = data['scheduledDate'] as String?;
      final startTime = data['startTime'] as String?;

      if (scheduledDate == null || startTime == null) {
        Log.i(runtimeType, '⚠️ No scheduledDate or startTime in data, using original body');
        return originalBody;
      }

      Log.i(runtimeType, '🕐 Converting UTC time to local timezone for SESSION_ACCEPTED');
      Log.i(runtimeType, '🕐 UTC Date: $scheduledDate');
      Log.i(runtimeType, '🕐 UTC Time: $startTime');

      final utcDateTime = SessionDateTimeUtils.parseUtcDateTime(scheduledDate, startTime);
      Log.i(runtimeType, '🕐 Parsed UTC DateTime: $utcDateTime');

      final localDateTime = utcDateTime.toLocal();
      Log.i(runtimeType, '🕐 Local DateTime: $localDateTime');

      final localizedBody = SessionDateTimeUtils.convertNotificationBodyToLocalTime(originalBody, scheduledDate, startTime);

      Log.i(runtimeType, '🕐 Localized notification body created');

      return localizedBody;
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Error converting time to local timezone: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
      return originalBody;
    }
  }
}
