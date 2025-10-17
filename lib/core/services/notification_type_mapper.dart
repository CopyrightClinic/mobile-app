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
        case PushNotificationType.sessionBookedSuccessfully:
        case PushNotificationType.aiAcceptsCase:
          result = NotificationType.sessionAccepted;
          break;

        case PushNotificationType.sessionCancelledByUser:
        case PushNotificationType.sessionCancelledByAttorney:
          result = NotificationType.sessionCancelled;
          break;

        case PushNotificationType.sessionReminderPreStart:
          result = NotificationType.sessionReminder;
          break;

        case PushNotificationType.sessionCompleted:
          result = NotificationType.sessionCompleted;
          break;

        case PushNotificationType.paymentReleasedToAttorney:
          result = NotificationType.paymentReleased;
          break;

        case PushNotificationType.paymentAuthorizationFailed:
          result = NotificationType.paymentAuthorizationFailed;
          break;

        case PushNotificationType.paymentHoldCreated:
        case PushNotificationType.refundIssued:
        case PushNotificationType.joinSessionActivated:
        case PushNotificationType.sessionSummaryAvailable:
        case PushNotificationType.summarySubmittedForReview:
        case PushNotificationType.summaryApproved:
        case PushNotificationType.accountDeletedSuccessfully:
        case PushNotificationType.attorneyAccountStatusChanged:
        case PushNotificationType.systemErrorAlert:
        case PushNotificationType.userFeedbackReceived:
        case PushNotificationType.attorneySelfReportedSession:
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
