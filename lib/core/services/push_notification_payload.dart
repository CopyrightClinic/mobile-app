import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/enumns/push/push_notification_type.dart';

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
