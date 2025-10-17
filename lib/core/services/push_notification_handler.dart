import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_router.dart';
import '../../config/routes/app_routes.dart';
import '../../features/sessions/presentation/pages/params/session_details_screen_params.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';
import 'push_notification_payload.dart';
import 'pending_navigation_service.dart';

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

        Log.i(runtimeType, '🎯 Now handling notification navigation on top of Home');
        await handleNotificationTap(pendingMessage, isFromPending: true);
      } else {
        Log.e(runtimeType, '❌ Context not available for pending navigation');
      }
    }
  }

  Future<void> _navigateBasedOnType(PushNotificationPayload payload) async {
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

    Log.i(runtimeType, '🧭 Determining navigation for type: ${payload.type.toApiString()}');

    switch (payload.type) {
      case PushNotificationType.aiAcceptsCase:
        Log.i(runtimeType, '🧭 → Navigating to Booking Request Sent');
        _navigateToBookingRequestSent(context);
        break;

      case PushNotificationType.sessionAccepted:
      case PushNotificationType.sessionBookedSuccessfully:
      case PushNotificationType.sessionReminderPreStart:
      case PushNotificationType.joinSessionActivated:
      case PushNotificationType.sessionCompleted:
      case PushNotificationType.sessionSummaryAvailable:
      case PushNotificationType.paymentHoldCreated:
      case PushNotificationType.summaryApproved:
        Log.i(runtimeType, '🧭 → Navigating to Session Details (ID: ${payload.sessionId})');
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.sessionCancelledByUser:
      case PushNotificationType.sessionCancelledByAttorney:
        Log.i(runtimeType, '🧭 → Navigating to Sessions List (session cancelled)');
        _navigateToSessions(context);
        break;

      case PushNotificationType.paymentReleasedToAttorney:
      case PushNotificationType.refundIssued:
        Log.i(runtimeType, '🧭 → Navigating to Sessions List (payment update)');
        _navigateToSessions(context);
        break;

      case PushNotificationType.paymentAuthorizationFailed:
        Log.i(runtimeType, '🧭 → Navigating to Payment Methods (payment failed)');
        _navigateToPaymentMethods(context);
        break;

      case PushNotificationType.summarySubmittedForReview:
      case PushNotificationType.systemErrorAlert:
      case PushNotificationType.userFeedbackReceived:
      case PushNotificationType.attorneySelfReportedSession:
        Log.i(runtimeType, '📋 Admin-only notification, no user navigation');
        break;

      case PushNotificationType.attorneyAccountStatusChanged:
      case PushNotificationType.accountDeletedSuccessfully:
        Log.i(runtimeType, '📋 Account notification, no navigation');
        break;
    }
  }

  void _navigateToSessionDetails(BuildContext context, String? sessionId) {
    if (sessionId == null) {
      Log.w(runtimeType, '⚠️ Session ID is null, falling back to sessions list');
      _navigateToSessions(context);
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

  void _navigateToSessions(BuildContext context) {
    try {
      Log.i(runtimeType, '✅ Using GoRouter.go to: ${AppRoutes.sessionsRouteName}');
      context.go(AppRoutes.sessionsRouteName);
      Log.i(runtimeType, '✅ Navigation completed successfully');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Navigation failed: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  void _navigateToBookingRequestSent(BuildContext context) {
    try {
      Log.i(runtimeType, '✅ Using GoRouter.push to: ${AppRoutes.bookingRequestSentRouteName}');
      context.push(AppRoutes.bookingRequestSentRouteName);
      Log.i(runtimeType, '✅ Navigation completed successfully');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Navigation failed: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  void _navigateToPaymentMethods(BuildContext context) {
    try {
      Log.i(runtimeType, '✅ Using GoRouter.push to: ${AppRoutes.paymentMethodsRouteName}');
      context.push(AppRoutes.paymentMethodsRouteName);
      Log.i(runtimeType, '✅ Navigation completed successfully');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Navigation failed: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }
}
