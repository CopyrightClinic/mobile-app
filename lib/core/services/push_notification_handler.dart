import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../analytics/analytics.dart';
import '../../config/routes/app_router.dart';
import '../../config/routes/app_routes.dart';
import '../../di.dart';
import '../../features/sessions/presentation/pages/params/session_details_screen_params.dart';
import '../../features/sessions/presentation/pages/params/extend_session_screen_params.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';
import 'push_notification_payload.dart';
import 'pending_navigation_service.dart';
import 'zoom_service.dart';

class PushNotificationHandler {
  static final PushNotificationHandler _instance = PushNotificationHandler._internal();
  factory PushNotificationHandler() => _instance;
  PushNotificationHandler._internal();

  final _pendingNavService = PendingNavigationService();

  void initialize() {
    _setupMessageHandlers();
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.i(runtimeType, '🔔 ========================================');
      Log.i(runtimeType, '🔔 NOTIFICATION TAPPED (App in Background)');
      Log.i(runtimeType, '🔔 ========================================');
      Log.i(runtimeType, '🔔 Message ID: ${message.messageId}');
      Log.i(runtimeType, '🔔 Data: ${message.data}');
      Log.i(runtimeType, '🔔 App was in background, navigating directly...');
      Log.i(runtimeType, '🔔 ========================================');

      Future.delayed(const Duration(milliseconds: 500), () {
        handleNotificationTap(message);
      });
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Log.i(runtimeType, '🚀 ========================================');
        Log.i(runtimeType, '🚀 NOTIFICATION OPENED APP (Was Terminated)');
        Log.i(runtimeType, '🚀 ========================================');
        Log.i(runtimeType, '🚀 Message ID: ${message.messageId}');
        Log.i(runtimeType, '🚀 Data: ${message.data}');
        Log.i(runtimeType, '🚀 Storing as PENDING - will navigate after splash');
        Log.i(runtimeType, '🚀 ========================================');

        _pendingNavService.setPendingNotification(message);
      } else {
        Log.i(runtimeType, '📱 App opened normally (not from notification)');
      }
    });
  }

  Future<void> handleNotificationTap(RemoteMessage message, {bool isFromPending = false}) async {
    try {
      Log.i(runtimeType, '🎯 ========================================');
      Log.i(runtimeType, '🎯 HANDLING NOTIFICATION TAP');
      if (isFromPending) {
        Log.i(runtimeType, '🎯 (Deferred from terminated state)');
      }
      Log.i(runtimeType, '🎯 ========================================');

      final payload = PushNotificationPayload.fromRemoteMessage(message);

      Log.i(runtimeType, '🎯 Parsed Type: ${payload.type.toApiString()}');
      Log.i(runtimeType, '🎯 Session ID: ${payload.sessionId ?? "N/A"}');
      Log.i(runtimeType, '🎯 Attorney Name: ${payload.attorneyName ?? "N/A"}');
      Log.i(runtimeType, '🎯 Amount: ${payload.amount ?? "N/A"}');
      Log.i(runtimeType, '🎯 Notification ID: ${payload.notificationId ?? "N/A"}');
      Log.i(runtimeType, '🎯 Raw Data Keys: ${payload.rawData.keys.toList()}');

      logAnalytics(
        AnalyticsEvents.notificationOpened,
        parameters: {
          'notification_type': payload.type.toApiString(),
          if (payload.sessionId != null) 'session_id': payload.sessionId!,
          if (payload.notificationId != null)
            'notification_id': payload.notificationId!,
        },
      );

      await _navigateBasedOnType(payload);

      if (isFromPending) {
        _pendingNavService.markAsHandled();
      }

      Log.i(runtimeType, '🎯 ========================================');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Error handling notification tap: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  Future<void> handlePendingNotificationIfExists() async {
    final pendingMessage = _pendingNavService.getPendingNotification();

    if (pendingMessage != null) {
      Log.i(runtimeType, '🎬 ========================================');
      Log.i(runtimeType, '🎬 EXECUTING PENDING NOTIFICATION NAVIGATION');
      Log.i(runtimeType, '🎬 Splash has completed, now navigating...');
      Log.i(runtimeType, '🎬 Step 1: Navigate to Home (replace splash)');
      Log.i(runtimeType, '🎬 Step 2: Push notification destination');
      Log.i(runtimeType, '🎬 ========================================');

      final context = AppRouter.router.routerDelegate.navigatorKey.currentContext;

      if (context != null && context.mounted) {
        Log.i(runtimeType, '🏠 Navigating to Home first (replaces splash in stack)');
        context.go(AppRoutes.homeRouteName);

        await Future.delayed(const Duration(milliseconds: 500));

        final payload = PushNotificationPayload.fromRemoteMessage(pendingMessage);

        if (payload.type.requiresNavigation) {
          Log.i(runtimeType, '🎯 Now handling notification navigation on top of Home');
          await handleNotificationTap(pendingMessage, isFromPending: true);
        } else {
          Log.i(runtimeType, '✅ Notification does not require navigation (${payload.type.toApiString()})');
          Log.i(runtimeType, '✅ Staying on Home screen');
          _pendingNavService.markAsHandled();
        }
      } else {
        Log.e(runtimeType, '❌ Context not available for pending navigation');
      }
    }
  }

  Future<void> _navigateBasedOnType(PushNotificationPayload payload) async {
    Log.i(runtimeType, '🧭 Determining navigation for type: ${payload.type.toApiString()}');

    if (!payload.type.requiresNavigation) {
      Log.i(runtimeType, '📋 Type ${payload.type.toApiString()} does not require navigation');
      return;
    }

    BuildContext? context = AppRouter.router.routerDelegate.navigatorKey.currentContext;

    if (context == null) {
      Log.w(runtimeType, '⚠️ GoRouter context is null, waiting...');

      for (int i = 0; i < 15; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        context = AppRouter.router.routerDelegate.navigatorKey.currentContext;
        if (context != null) {
          Log.i(runtimeType, '✅ GoRouter context is now available after ${(i + 1) * 200}ms');
          break;
        }
      }

      if (context == null) {
        Log.e(runtimeType, '❌ GoRouter context still null after 3 seconds, aborting navigation');
        return;
      }
    }

    if (!context.mounted) {
      Log.w(runtimeType, '⚠️ Context is no longer mounted, aborting navigation');
      return;
    }
    switch (payload.type) {
      case PushNotificationType.sessionAccepted:
      case PushNotificationType.sessionReminder:
      case PushNotificationType.sessionCompleted:
      case PushNotificationType.sessionSummaryAvailable:
        Log.i(runtimeType, '🧭 → Navigating to Session Details (ID: ${payload.sessionId})');
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.sessionExtensionPrompt:
        Log.i(runtimeType, '🧭 → Navigating to Extend Session (ID: ${payload.sessionId}, Fee: \$${payload.totalFee})');
        _navigateToExtendSession(context, payload.sessionId, payload.totalFee);
        break;

      case PushNotificationType.sessionRequestExpired:
        Log.i(runtimeType, '🧭 → Navigating to Notifications');
        _navigateToNotifications(context);
        break;

      case PushNotificationType.refundIssued:
        Log.i(runtimeType, '📋 Refund notification, no navigation (handled by requiresNavigation check)');
        break;
    }
  }

  void _navigateToNotifications(BuildContext context) {
    try {
      Log.i(runtimeType, '✅ Using GoRouter.push to: ${AppRoutes.notificationsRouteName}');
      context.push(AppRoutes.notificationsRouteName);
      Log.i(runtimeType, '✅ Navigation completed successfully');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Navigation failed: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  void _navigateToSessionDetails(BuildContext context, String? sessionId) {
    if (sessionId == null) {
      Log.w(runtimeType, '⚠️ Session ID is null, cannot navigate to session details');
      return;
    }

    try {
      Log.i(runtimeType, '✅ Using GoRouter.push to: ${AppRoutes.sessionDetailsRouteName}');
      Log.i(runtimeType, '✅ Session ID: $sessionId');

      context.push(AppRoutes.sessionDetailsRouteName, extra: SessionDetailsScreenParams(sessionId: sessionId));

      Log.i(runtimeType, '✅ Navigation completed successfully');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Navigation failed: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  void _navigateToExtendSession(BuildContext context, String? sessionId, double? totalFee) async {
    if (sessionId == null) {
      Log.w(runtimeType, '⚠️ Session ID is null, cannot navigate to extend session');
      return;
    }

    if (totalFee == null) {
      Log.w(runtimeType, '⚠️ Total Fee is null, cannot navigate to extend session');
      return;
    }

    try {
      final zoomService = sl<ZoomService>();

      try {
        Log.i(runtimeType, '📱 Attempting to minimize Zoom meeting...');
        await zoomService.minimizeMeeting();
        Log.i(runtimeType, '✅ Zoom meeting minimized successfully');

        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        Log.w(runtimeType, '⚠️ Could not minimize Zoom meeting (might not be in a meeting): $e');
      }

      Log.i(runtimeType, '✅ Using GoRouter.push to: ${AppRoutes.extendSessionRouteName}');
      Log.i(runtimeType, '✅ Session ID from notification: $sessionId');
      Log.i(runtimeType, '💰 Total Fee from notification: \$${totalFee.toStringAsFixed(2)}');

      context.push(AppRoutes.extendSessionRouteName, extra: ExtendSessionScreenParams(sessionId: sessionId, totalFee: totalFee));

      Log.i(runtimeType, '✅ Navigation to extend session completed successfully');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Navigation to extend session failed: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }
}
