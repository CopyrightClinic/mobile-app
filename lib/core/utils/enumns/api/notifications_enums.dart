enum NotificationType {
  sessionAccepted,
  refundIssued,
  sessionReminder,
  sessionCompleted,
  sessionSummaryAvailable,
  sessionExtensionApproved,
  sessionExtensionDeclined,
  sessionExtensionPrompt,
  sessionCancelled,
  sessionRequestExpired;

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SESSION_ACCEPTED':
        return NotificationType.sessionAccepted;
      case 'REFUND_ISSUED':
        return NotificationType.refundIssued;
      case 'SESSION_REMINDER':
        return NotificationType.sessionReminder;
      case 'SESSION_COMPLETED':
        return NotificationType.sessionCompleted;
      case 'SESSION_SUMMARY_AVAILABLE':
        return NotificationType.sessionSummaryAvailable;
      case 'SESSION_EXTENSION_APPROVED':
        return NotificationType.sessionExtensionApproved;
      case 'SESSION_EXTENSION_DECLINED':
        return NotificationType.sessionExtensionDeclined;
      case 'SESSION_EXTENSION_PROMPT':
        return NotificationType.sessionExtensionPrompt;
      case 'PAYMENT_HOLD_RELEASED':
        return NotificationType.sessionCancelled;
      case 'SESSION_REQUEST_EXPIRED':
        return NotificationType.sessionRequestExpired;
      default:
        return NotificationType.sessionReminder;
    }
  }

  String toApiString() {
    switch (this) {
      case NotificationType.sessionAccepted:
        return 'SESSION_ACCEPTED';
      case NotificationType.refundIssued:
        return 'REFUND_ISSUED';
      case NotificationType.sessionReminder:
        return 'SESSION_REMINDER';
      case NotificationType.sessionCompleted:
        return 'SESSION_COMPLETED';
      case NotificationType.sessionSummaryAvailable:
        return 'SESSION_SUMMARY_AVAILABLE';
      case NotificationType.sessionExtensionApproved:
        return 'SESSION_EXTENSION_APPROVED';
      case NotificationType.sessionExtensionDeclined:
        return 'SESSION_EXTENSION_DECLINED';
      case NotificationType.sessionExtensionPrompt:
        return 'SESSION_EXTENSION_PROMPT';
      case NotificationType.sessionCancelled:
        return 'PAYMENT_HOLD_RELEASED';
      case NotificationType.sessionRequestExpired:
        return 'SESSION_REQUEST_EXPIRED';
    }
  }
}
