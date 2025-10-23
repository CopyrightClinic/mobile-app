enum NotificationType {
  sessionAccepted,
  sessionCancelled,
  sessionReminder,
  paymentReleased,
  paymentReceived,
  paymentAuthorizationFailed,
  sessionCompleted;

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SESSION_ACCEPTED':
        return NotificationType.sessionAccepted;
      case 'SESSION_CANCELLED':
        return NotificationType.sessionCancelled;
      case 'SESSION_REMINDER':
        return NotificationType.sessionReminder;
      case 'PAYMENT_RELEASED':
        return NotificationType.paymentReleased;
      case 'PAYMENT_RECEIVED':
        return NotificationType.paymentReceived;
      case 'PAYMENT_AUTHORIZATION_FAILED':
        return NotificationType.paymentAuthorizationFailed;
      case 'SESSION_COMPLETED':
        return NotificationType.sessionCompleted;
      default:
        return NotificationType.sessionReminder;
    }
  }

  String toApiString() {
    switch (this) {
      case NotificationType.sessionAccepted:
        return 'SESSION_ACCEPTED';
      case NotificationType.sessionCancelled:
        return 'SESSION_CANCELLED';
      case NotificationType.sessionReminder:
        return 'SESSION_REMINDER';
      case NotificationType.paymentReleased:
        return 'PAYMENT_RELEASED';
      case NotificationType.paymentReceived:
        return 'PAYMENT_RECEIVED';
      case NotificationType.paymentAuthorizationFailed:
        return 'PAYMENT_AUTHORIZATION_FAILED';
      case NotificationType.sessionCompleted:
        return 'SESSION_COMPLETED';
    }
  }
}
