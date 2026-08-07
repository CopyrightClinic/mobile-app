import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/notification_action_constants.dart';
import '../utils/logger/logger.dart';
import 'pending_navigation_service.dart';
import 'push_notification_handler.dart';
import 'session_extension_action_service.dart';

/// Entry point used by flutter_local_notifications when an action button is
/// tapped while the app is in the background or terminated. It runs in its own
/// isolate, so nothing from the running app (DI, blocs, navigator) is available
/// here.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  NotificationActionRouter.handleResponse(response, fromBackgroundIsolate: true);
}

class NotificationActionRouter {
  const NotificationActionRouter._();

  static Future<void> handleResponse(
    NotificationResponse response, {
    bool fromBackgroundIsolate = false,
    bool isAppLaunch = false,
  }) async {
    Log.i('NotificationActionRouter', '👆 ========================================');
    Log.i('NotificationActionRouter', '👆 NOTIFICATION RESPONSE');
    Log.i('NotificationActionRouter', '👆 Action ID: ${response.actionId ?? "(body tap)"}');
    Log.i('NotificationActionRouter', '👆 Background isolate: $fromBackgroundIsolate');
    Log.i('NotificationActionRouter', '👆 App launch: $isAppLaunch');

    final data = _decodePayload(response.payload);
    if (data == null) {
      Log.w('NotificationActionRouter', '⚠️ No usable payload in notification response');
      return;
    }

    final sessionId = data['sessionId'] as String?;

    switch (response.actionId) {
      case NotificationActionConstants.declineExtensionActionId:
        if (sessionId == null) {
          Log.w('NotificationActionRouter', '⚠️ Decline tapped but sessionId is missing');
          return;
        }
        await SessionExtensionActionService.declineExtension(sessionId);
        return;

      case NotificationActionConstants.acceptExtensionActionId:
      default:
        // Accept and plain body taps both open the existing extension flow.
        if (fromBackgroundIsolate) {
          Log.w('NotificationActionRouter', '⚠️ Foreground action reached the background isolate, ignoring');
          return;
        }
        _openNotification(RemoteMessage(data: data), isAppLaunch: isAppLaunch);
        return;
    }
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
