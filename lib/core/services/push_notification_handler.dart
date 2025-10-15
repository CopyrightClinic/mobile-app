import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../features/sessions/presentation/pages/params/session_details_screen_params.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';

class PushNotificationPayload {
  final PushNotificationType type;
  final String? sessionId;
  final String? attorneyName;
  final String? amount;
  final String? notificationId;
  final Map<String, dynamic> rawData;

  const PushNotificationPayload({required this.type, this.sessionId, this.attorneyName, this.amount, this.notificationId, required this.rawData});

  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final typeString = data['type'] as String?;

    if (typeString == null) {
      throw ArgumentError('Push notification type is missing');
    }

    return PushNotificationPayload(
      type: PushNotificationType.fromString(typeString),
      sessionId: data['sessionId'] as String?,
      attorneyName: data['attorneyName'] as String?,
      amount: data['amount'] as String?,
      notificationId: data['notificationId'] as String?,
      rawData: data,
    );
  }
}

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
      Log.i(runtimeType, 'Notification tapped (app in background): ${message.data}');
      handleNotificationTap(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Log.i(runtimeType, 'Notification tapped (app was terminated): ${message.data}');
        Future.delayed(const Duration(seconds: 1), () {
          handleNotificationTap(message);
        });
      }
    });
  }

  Future<void> handleNotificationTap(RemoteMessage message) async {
    try {
      final payload = PushNotificationPayload.fromRemoteMessage(message);

      Log.i(runtimeType, 'Handling notification type: ${payload.type}');

      await _navigateBasedOnType(payload);
    } catch (e) {
      Log.e(runtimeType, 'Error handling notification tap: $e');
    }
  }

  Future<void> _navigateBasedOnType(PushNotificationPayload payload) async {
    final context = _navigatorKey?.currentContext ?? _context;
    if (context == null) {
      Log.w(runtimeType, 'Navigation context is null, cannot navigate');
      return;
    }

    switch (payload.type) {
      case PushNotificationType.aiAcceptsCase:
        _navigateToBookingRequestSent(context);
        break;

      case PushNotificationType.sessionBookedSuccessfully:
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.sessionReminderPreStart:
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.joinSessionActivated:
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.sessionCancelledByUser:
      case PushNotificationType.sessionCancelledByAttorney:
        _navigateToSessions(context);
        break;

      case PushNotificationType.sessionCompleted:
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.sessionSummaryAvailable:
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.paymentHoldCreated:
      case PushNotificationType.paymentHoldReleased:
        _navigateToSessionDetails(context, payload.sessionId);
        break;

      case PushNotificationType.failedPayment:
        _navigateToPaymentMethods(context);
        break;

      case PushNotificationType.accountDeleted:
        break;
    }
  }

  void _navigateToSessionDetails(BuildContext context, String? sessionId) {
    if (sessionId == null) {
      Log.w(runtimeType, 'Session ID is null, navigating to sessions list');
      _navigateToSessions(context);
      return;
    }

    context.push(AppRoutes.sessionDetailsRouteName, extra: SessionDetailsScreenParams(sessionId: sessionId));
  }

  void _navigateToSessions(BuildContext context) {
    context.go(AppRoutes.sessionsRouteName);
  }

  void _navigateToBookingRequestSent(BuildContext context) {
    context.push(AppRoutes.bookingRequestSentRouteName);
  }

  void _navigateToPaymentMethods(BuildContext context) {
    context.push(AppRoutes.paymentMethodsRouteName);
  }
}
