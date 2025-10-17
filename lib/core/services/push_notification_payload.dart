import 'package:firebase_messaging/firebase_messaging.dart';

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

    Log.i('PushNotificationPayload', '📦 ========================================');
    Log.i('PushNotificationPayload', '📦 PARSING NOTIFICATION PAYLOAD');
    Log.i('PushNotificationPayload', '📦 ========================================');
    Log.i('PushNotificationPayload', '📦 Raw Data: $data');

    final typeString = data['type'] as String?;
    Log.i('PushNotificationPayload', '📦 Type String: $typeString');

    if (typeString == null) {
      Log.e('PushNotificationPayload', '❌ Push notification type is missing in data!');
      throw ArgumentError('Push notification type is missing');
    }

    final sessionId = data['sessionId'] as String?;
    final attorneyName = data['attorneyName'] as String?;
    final amount = data['amount'] as String?;
    final notificationId = data['notificationId'] as String?;

    Log.i('PushNotificationPayload', '📦 Extracted Fields:');
    Log.i('PushNotificationPayload', '📦   - sessionId: $sessionId');
    Log.i('PushNotificationPayload', '📦   - attorneyName: $attorneyName');
    Log.i('PushNotificationPayload', '📦   - amount: $amount');
    Log.i('PushNotificationPayload', '📦   - notificationId: $notificationId');

    try {
      final parsedType = PushNotificationType.fromString(typeString);
      Log.i('PushNotificationPayload', '✅ Successfully parsed type: ${parsedType.toApiString()}');
      Log.i('PushNotificationPayload', '📦 ========================================');

      return PushNotificationPayload(
        type: parsedType,
        sessionId: sessionId,
        attorneyName: attorneyName,
        amount: amount,
        notificationId: notificationId,
        rawData: data,
      );
    } catch (e, stackTrace) {
      Log.e('PushNotificationPayload', '❌ Failed to parse notification type: $typeString');
      Log.e('PushNotificationPayload', 'Error: $e');
      Log.e('PushNotificationPayload', 'Stack trace: $stackTrace');
      rethrow;
    }
  }
}
