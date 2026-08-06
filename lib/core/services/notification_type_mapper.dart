import '../utils/enumns/api/notifications_enums.dart';
import '../utils/enumns/push/push_notification_type.dart';
import '../utils/logger/logger.dart';

class NotificationTypeMapper {
  static NotificationType? mapFCMToInApp(String fcmType) {
    Log.i('NotificationTypeMapper', '🔄 Mapping FCM type to in-app: $fcmType');

    try {
      final pushType = PushNotificationType.fromString(fcmType);

      NotificationType? result;

      switch (pushType) {
        case PushNotificationType.sessionAccepted:
          result = NotificationType.sessionAccepted;
          break;

        case PushNotificationType.sessionReminder:
          result = NotificationType.sessionReminder;
          break;

        case PushNotificationType.sessionCompleted:
          result = NotificationType.sessionCompleted;
          break;

        case PushNotificationType.sessionRequestExpired:
          result = NotificationType.sessionRequestExpired;
          break;

        case PushNotificationType.sessionSummaryAvailable:
        case PushNotificationType.refundIssued:
        case PushNotificationType.sessionExtensionPrompt:
          result = null;
          break;
      }

      if (result != null) {
        Log.i('NotificationTypeMapper', '✅ Mapped: $fcmType → ${result.toApiString()}');
      } else {
        Log.i('NotificationTypeMapper', '📲 Push-only: $fcmType (no in-app mapping)');
      }

      return result;
    } catch (e) {
      Log.e('NotificationTypeMapper', '❌ Error mapping type: $fcmType - $e');
      return null;
    }
  }

  static bool shouldCreateInAppNotification(String fcmType) {
    return mapFCMToInApp(fcmType) != null;
  }
}
