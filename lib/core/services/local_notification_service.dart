import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_strings.dart';
import '../constants/notification_action_constants.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';
import '../utils/session_datetime_utils.dart';
import 'notification_action_router.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Permissions are requested by FCMService once the user is authenticated,
    // so this initialization must stay silent.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();

    _isInitialized = true;
    Log.i(runtimeType, 'Local notifications initialized');

    await _handleAppLaunchDetails();
  }

  /// Pre-creates channels at IMPORTANCE_HIGH so heads-up display works even
  /// for FCM "notification"-payload messages the OS auto-displays (which
  /// would otherwise create the channel at a lower default importance).
  /// Channel importance is immutable once created, so channel IDs here must
  /// stay in sync with [_getChannelId]/[AndroidManifest.xml]'s
  /// default_notification_channel_id.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    const channels = [
      AndroidNotificationChannel(
        'session_channel_v2',
        'Session Notifications',
        description: 'Copyright Clinic notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'payment_channel_v2',
        'Payment Notifications',
        description: 'Copyright Clinic notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'default_channel_v2',
        'Default Notifications',
        description: 'Copyright Clinic notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Picks up a tap that launched the app from a terminated state.
  /// flutter_local_notifications does not replay those through
  /// [_onNotificationTapped].
  Future<void> _handleAppLaunchDetails() async {
    try {
      final details = await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

      if (details == null || !details.didNotificationLaunchApp) return;

      final response = details.notificationResponse;
      if (response == null) return;

      Log.i(runtimeType, '🚀 App launched from local notification');

      // Deliberately not awaited: the pending navigation is registered
      // synchronously and startup must not block on any network work.
      unawaited(NotificationActionRouter.handleResponse(response, isAppLaunch: true));
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Error reading notification launch details: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    NotificationActionRouter.handleResponse(response);
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

      final notificationType = _getNotificationType(data);
      final isExtensionPrompt = notificationType == PushNotificationType.sessionExtensionPrompt;

      final title = notification?.title ?? data['title'] as String?;
      final body = notification?.body ?? data['body'] as String?;

      if (!isExtensionPrompt && title == null && body == null) {
        Log.w(runtimeType, '⚠️ Nothing to display for this message, skipping');
        return;
      }

      Log.i(runtimeType, '🔔 Notification Type: ${notificationType?.toApiString() ?? "Unknown"}');
      Log.i(runtimeType, '🔔 Title: $title');
      Log.i(runtimeType, '🔔 Body (Original): $body');

      final displayTitle = isExtensionPrompt ? _localized(AppStrings.extendYourSession, 'Extend your session') : (title ?? 'Copyright Clinic');
      final displayBody = isExtensionPrompt
          ? _localized(AppStrings.extendSessionPromptBody, 'Click/tap here to extend an additional 30 minutes')
          : await _getLocalizedNotificationBody(body, data, notificationType);

      final androidDetails = _getAndroidNotificationDetails(notificationType);
      final iosDetails = _getIOSNotificationDetails(notificationType);

      Log.i(runtimeType, '🔔 Android Channel: ${androidDetails.channelId}');
      Log.i(runtimeType, '🔔 Android Priority: ${androidDetails.priority}');
      Log.i(runtimeType, '🔔 iOS Interruption Level: ${iosDetails.interruptionLevel}');

      await _flutterLocalNotificationsPlugin.show(
        isExtensionPrompt ? NotificationActionConstants.sessionExtensionNotificationId : message.hashCode,
        displayTitle,
        displayBody,
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
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: _getIOSInterruptionLevel(type),
    );
  }

  /// easy_localization is not available inside the background isolate, so every
  /// notification string needs a hardcoded fallback.
  String _localized(String key, String fallback) {
    try {
      final value = key.tr();
      return value == key ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  String _getChannelId(PushNotificationType? type) {
    if (type == null) return 'default_channel_v2';

    if (type.isSessionRelated) {
      return 'session_channel_v2';
    } else if (type.isPaymentRelated) {
      return 'payment_channel_v2';
    }
    return 'default_channel_v2';
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

  Importance _getImportance(PushNotificationType? type) => Importance.high;

  Priority _getPriority(PushNotificationType? type) => Priority.high;

  InterruptionLevel _getIOSInterruptionLevel(PushNotificationType? type) {
    if (type == null) return InterruptionLevel.active;

    switch (type) {
      case PushNotificationType.sessionReminder:
      case PushNotificationType.sessionExtensionPrompt:
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

  Future<String?> _getLocalizedNotificationBody(String? originalBody, Map<String, dynamic> data, PushNotificationType? notificationType) async {
    if (originalBody == null || originalBody.isEmpty) {
      return null;
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
