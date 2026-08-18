import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/logger/logger.dart';
import 'pending_navigation_service.dart';
import 'push_notification_handler.dart';

class NotificationActionRouter {
  const NotificationActionRouter._();

  static Future<void> handleResponse(
    NotificationResponse response, {
    bool isAppLaunch = false,
  }) async {
    Log.i('NotificationActionRouter', '👆 ========================================');
    Log.i('NotificationActionRouter', '👆 NOTIFICATION RESPONSE');
    Log.i('NotificationActionRouter', '👆 App launch: $isAppLaunch');

    final data = _decodePayload(response.payload);
    if (data == null) {
      Log.w('NotificationActionRouter', '⚠️ No usable payload in notification response');
      return;
    }

    _openNotification(RemoteMessage(data: data), isAppLaunch: isAppLaunch);
  }

  static void _openNotification(RemoteMessage message, {required bool isAppLaunch}) {
    if (isAppLaunch) {
      PendingNavigationService().setPendingNotification(message);
      return;
    }

    PushNotificationHandler().handleNotificationTap(message);
  }

  static Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (e) {
      Log.e('NotificationActionRouter', '❌ Could not decode notification payload: $e');
      return null;
    }
  }
}
