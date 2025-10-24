enum PushNotificationType {
  sessionAccepted,
  refundIssued,
  sessionReminder,
  sessionCompleted,
  sessionSummaryAvailable;

  static PushNotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SESSION_ACCEPTED':
        return PushNotificationType.sessionAccepted;
      case 'REFUND_ISSUED':
        return PushNotificationType.refundIssued;
      case 'SESSION_REMINDER':
        return PushNotificationType.sessionReminder;
      case 'SESSION_COMPLETED':
        return PushNotificationType.sessionCompleted;
      case 'SESSION_SUMMARY_AVAILABLE':
        return PushNotificationType.sessionSummaryAvailable;
      default:
        throw ArgumentError('Unknown push notification type: $value');
    }
  }

  String toApiString() {
    switch (this) {
      case PushNotificationType.sessionAccepted:
        return 'SESSION_ACCEPTED';
      case PushNotificationType.refundIssued:
        return 'REFUND_ISSUED';
      case PushNotificationType.sessionReminder:
        return 'SESSION_REMINDER';
      case PushNotificationType.sessionCompleted:
        return 'SESSION_COMPLETED';
      case PushNotificationType.sessionSummaryAvailable:
        return 'SESSION_SUMMARY_AVAILABLE';
    }
  }

  bool get requiresNavigation {
    switch (this) {
      case PushNotificationType.sessionAccepted:
      case PushNotificationType.sessionReminder:
      case PushNotificationType.sessionCompleted:
      case PushNotificationType.sessionSummaryAvailable:
        return true;
      case PushNotificationType.refundIssued:
        return false;
    }
  }

  bool get isSessionRelated {
    switch (this) {
      case PushNotificationType.sessionAccepted:
      case PushNotificationType.sessionReminder:
      case PushNotificationType.sessionCompleted:
      case PushNotificationType.sessionSummaryAvailable:
        return true;
      case PushNotificationType.refundIssued:
        return false;
    }
  }

  bool get isPaymentRelated {
    switch (this) {
      case PushNotificationType.refundIssued:
        return true;
      default:
        return false;
    }
  }
}
