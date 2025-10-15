enum PushNotificationType {
  aiAcceptsCase,
  sessionBookedSuccessfully,
  paymentHoldCreated,
  paymentHoldReleased,
  sessionReminderPreStart,
  joinSessionActivated,
  sessionCancelledByUser,
  sessionCancelledByAttorney,
  sessionCompleted,
  sessionSummaryAvailable,
  failedPayment,
  accountDeleted;

  static PushNotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AI_ACCEPTS_CASE':
        return PushNotificationType.aiAcceptsCase;
      case 'SESSION_BOOKED_SUCCESSFULLY':
        return PushNotificationType.sessionBookedSuccessfully;
      case 'PAYMENT_HOLD_CREATED':
        return PushNotificationType.paymentHoldCreated;
      case 'PAYMENT_HOLD_RELEASED':
        return PushNotificationType.paymentHoldReleased;
      case 'SESSION_REMINDER_PRE_START':
        return PushNotificationType.sessionReminderPreStart;
      case 'JOIN_SESSION_ACTIVATED':
        return PushNotificationType.joinSessionActivated;
      case 'SESSION_CANCELLED_BY_USER':
        return PushNotificationType.sessionCancelledByUser;
      case 'SESSION_CANCELLED_BY_ATTORNEY':
        return PushNotificationType.sessionCancelledByAttorney;
      case 'SESSION_COMPLETED':
        return PushNotificationType.sessionCompleted;
      case 'SESSION_SUMMARY_AVAILABLE':
        return PushNotificationType.sessionSummaryAvailable;
      case 'FAILED_PAYMENT':
        return PushNotificationType.failedPayment;
      case 'ACCOUNT_DELETED':
        return PushNotificationType.accountDeleted;
      default:
        throw ArgumentError('Unknown push notification type: $value');
    }
  }

  String toApiString() {
    switch (this) {
      case PushNotificationType.aiAcceptsCase:
        return 'AI_ACCEPTS_CASE';
      case PushNotificationType.sessionBookedSuccessfully:
        return 'SESSION_BOOKED_SUCCESSFULLY';
      case PushNotificationType.paymentHoldCreated:
        return 'PAYMENT_HOLD_CREATED';
      case PushNotificationType.paymentHoldReleased:
        return 'PAYMENT_HOLD_RELEASED';
      case PushNotificationType.sessionReminderPreStart:
        return 'SESSION_REMINDER_PRE_START';
      case PushNotificationType.joinSessionActivated:
        return 'JOIN_SESSION_ACTIVATED';
      case PushNotificationType.sessionCancelledByUser:
        return 'SESSION_CANCELLED_BY_USER';
      case PushNotificationType.sessionCancelledByAttorney:
        return 'SESSION_CANCELLED_BY_ATTORNEY';
      case PushNotificationType.sessionCompleted:
        return 'SESSION_COMPLETED';
      case PushNotificationType.sessionSummaryAvailable:
        return 'SESSION_SUMMARY_AVAILABLE';
      case PushNotificationType.failedPayment:
        return 'FAILED_PAYMENT';
      case PushNotificationType.accountDeleted:
        return 'ACCOUNT_DELETED';
    }
  }

  bool get requiresNavigation {
    switch (this) {
      case PushNotificationType.aiAcceptsCase:
      case PushNotificationType.sessionBookedSuccessfully:
      case PushNotificationType.sessionReminderPreStart:
      case PushNotificationType.joinSessionActivated:
      case PushNotificationType.sessionCancelledByUser:
      case PushNotificationType.sessionCancelledByAttorney:
      case PushNotificationType.sessionCompleted:
      case PushNotificationType.sessionSummaryAvailable:
        return true;
      case PushNotificationType.paymentHoldCreated:
      case PushNotificationType.paymentHoldReleased:
      case PushNotificationType.failedPayment:
      case PushNotificationType.accountDeleted:
        return false;
    }
  }

  bool get isSessionRelated {
    switch (this) {
      case PushNotificationType.aiAcceptsCase:
      case PushNotificationType.sessionBookedSuccessfully:
      case PushNotificationType.sessionReminderPreStart:
      case PushNotificationType.joinSessionActivated:
      case PushNotificationType.sessionCancelledByUser:
      case PushNotificationType.sessionCancelledByAttorney:
      case PushNotificationType.sessionCompleted:
      case PushNotificationType.sessionSummaryAvailable:
        return true;
      default:
        return false;
    }
  }

  bool get isPaymentRelated {
    switch (this) {
      case PushNotificationType.paymentHoldCreated:
      case PushNotificationType.paymentHoldReleased:
      case PushNotificationType.failedPayment:
        return true;
      default:
        return false;
    }
  }
}
