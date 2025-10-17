import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../features/sessions/presentation/pages/params/session_details_screen_params.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';
import 'push_notification_payload.dart';

class PushNotificationHandler {
  static final PushNotificationHandler _instance = PushNotificationHandler._internal();
  factory PushNotificationHandler() => _instance;
  PushNotificationHandler._internal();

  BuildContext? _context;
  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _setupMessageHandlers();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.i(runtimeType, '🔔 ========================================');
      Log.i(runtimeType, '🔔 NOTIFICATION TAPPED (App in Background)');
      Log.i(runtimeType, '🔔 ========================================');
      Log.i(runtimeType, '🔔 Message ID: ${message.messageId}');
      Log.i(runtimeType, '🔔 Data: ${message.data}');
      Log.i(runtimeType, '🔔 ========================================');
      handleNotificationTap(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Log.i(runtimeType, '🚀 ========================================');
        Log.i(runtimeType, '🚀 NOTIFICATION OPENED APP (Was Terminated)');
        Log.i(runtimeType, '🚀 ========================================');
        Log.i(runtimeType, '🚀 Message ID: ${message.messageId}');
        Log.i(runtimeType, '🚀 Data: ${message.data}');
        Log.i(runtimeType, '🚀 Waiting 1 second for app to initialize...');
        Log.i(runtimeType, '🚀 ========================================');
        Future.delayed(const Duration(seconds: 1), () {
          handleNotificationTap(message);
        });
      } else {
        Log.i(runtimeType, '📱 App opened normally (not from notification)');
      }
    });
  }

  Future<void> handleNotificationTap(RemoteMessage message) async {
    try {
      Log.i(runtimeType, '🎯 ========================================');
      Log.i(runtimeType, '🎯 HANDLING NOTIFICATION TAP');
      Log.i(runtimeType, '🎯 ========================================');

      final payload = PushNotificationPayload.fromRemoteMessage(message);

      Log.i(runtimeType, '🎯 Parsed Type: ${payload.type.toApiString()}');
      Log.i(runtimeType, '🎯 Session ID: ${payload.sessionId ?? "N/A"}');
      Log.i(runtimeType, '🎯 Attorney Name: ${payload.attorneyName ?? "N/A"}');
      Log.i(runtimeType, '🎯 Amount: ${payload.amount ?? "N/A"}');
      Log.i(runtimeType, '🎯 Notification ID: ${payload.notificationId ?? "N/A"}');
      Log.i(runtimeType, '🎯 Raw Data Keys: ${payload.rawData.keys.toList()}');

      await _navigateBasedOnType(payload);

      Log.i(runtimeType, '🎯 ========================================');
    } catch (e, stackTrace) {
      Log.e(runtimeType, '❌ Error handling notification tap: $e');
      Log.e(runtimeType, 'Stack trace: $stackTrace');
    }
  }

  Future<void> _navigateBasedOnType(PushNotificationPayload payload) async {
    final context = _navigatorKey?.currentContext ?? _context;
    if (context == null) {
      Log.w(runtimeType, '⚠️ Navigation context is null, cannot navigate');
      return;
    }

    Log.i(runtimeType, '🧭 Determining navigation for type: ${payload.type.toApiString()}');

    switch (payload.type) {
      case PushNotificationType.aiAcceptsCase:
        Log.i(runtimeType, '🧭 → Navigating to Booking Request Sent');
        _navigateToBookingRequestSent(context);
        break;

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

    Log.i(runtimeType, '✅ Navigating: ${AppRoutes.sessionDetailsRouteName} with sessionId: $sessionId');
    context.push(AppRoutes.sessionDetailsRouteName, extra: SessionDetailsScreenParams(sessionId: sessionId));
    Log.i(runtimeType, '✅ Navigation completed');
  }

  void _navigateToSessions(BuildContext context) {
    Log.i(runtimeType, '✅ Navigating: ${AppRoutes.sessionsRouteName}');
    context.go(AppRoutes.sessionsRouteName);
    Log.i(runtimeType, '✅ Navigation completed');
  }

  void _navigateToBookingRequestSent(BuildContext context) {
    Log.i(runtimeType, '✅ Navigating: ${AppRoutes.bookingRequestSentRouteName}');
    context.push(AppRoutes.bookingRequestSentRouteName);
    Log.i(runtimeType, '✅ Navigation completed');
  }

  void _navigateToPaymentMethods(BuildContext context) {
    Log.i(runtimeType, '✅ Navigating: ${AppRoutes.paymentMethodsRouteName}');
    context.push(AppRoutes.paymentMethodsRouteName);
    Log.i(runtimeType, '✅ Navigation completed');
  }
}
