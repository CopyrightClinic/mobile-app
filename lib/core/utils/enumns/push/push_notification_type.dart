enum PushNotificationType {
  aiAcceptsCase,
  sessionBookedSuccessfully,
  paymentHoldCreated,
  paymentReleasedToAttorney,
  refundIssued,
  sessionReminderPreStart,
  joinSessionActivated,
  sessionCancelledByUser,
  sessionCancelledByAttorney,
  sessionCompleted,
  sessionSummaryAvailable,
  summarySubmittedForReview,
  summaryApproved,
  paymentAuthorizationFailed,
  accountDeletedSuccessfully,
  attorneyAccountStatusChanged,
  systemErrorAlert,
  userFeedbackReceived,
  attorneySelfReportedSession;

  static PushNotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AI_ACCEPTS_CASE':
        return PushNotificationType.aiAcceptsCase;
      case 'SESSION_BOOKED_SUCCESSFULLY':
        return PushNotificationType.sessionBookedSuccessfully;
      case 'PAYMENT_HOLD_CREATED':
        return PushNotificationType.paymentHoldCreated;
      case 'PAYMENT_RELEASED_TO_ATTORNEY':
        return PushNotificationType.paymentReleasedToAttorney;
      case 'REFUND_ISSUED':
        return PushNotificationType.refundIssued;
      case 'SESSION_REMINDER':
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
      case 'SUMMARY_SUBMITTED_FOR_REVIEW':
        return PushNotificationType.summarySubmittedForReview;
      case 'SUMMARY_APPROVED':
        return PushNotificationType.summaryApproved;
      case 'PAYMENT_AUTHORIZATION_FAILED':
      case 'FAILED_PAYMENT':
        return PushNotificationType.paymentAuthorizationFailed;
      case 'ACCOUNT_DELETED_SUCCESSFULLY':
      case 'ACCOUNT_DELETED':
        return PushNotificationType.accountDeletedSuccessfully;
      case 'ATTORNEY_ACCOUNT_STATUS_CHANGED':
        return PushNotificationType.attorneyAccountStatusChanged;
      case 'SYSTEM_ERROR_ALERT':
        return PushNotificationType.systemErrorAlert;
      case 'USER_FEEDBACK_RECEIVED':
        return PushNotificationType.userFeedbackReceived;
      case 'ATTORNEY_SELF_REPORTED_SESSION':
        return PushNotificationType.attorneySelfReportedSession;
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
      case PushNotificationType.paymentReleasedToAttorney:
        return 'PAYMENT_RELEASED_TO_ATTORNEY';
      case PushNotificationType.refundIssued:
        return 'REFUND_ISSUED';
      case PushNotificationType.sessionReminderPreStart:
        return 'SESSION_REMINDER';
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
      case PushNotificationType.summarySubmittedForReview:
        return 'SUMMARY_SUBMITTED_FOR_REVIEW';
      case PushNotificationType.summaryApproved:
        return 'SUMMARY_APPROVED';
      case PushNotificationType.paymentAuthorizationFailed:
        return 'PAYMENT_AUTHORIZATION_FAILED';
      case PushNotificationType.accountDeletedSuccessfully:
        return 'ACCOUNT_DELETED_SUCCESSFULLY';
      case PushNotificationType.attorneyAccountStatusChanged:
        return 'ATTORNEY_ACCOUNT_STATUS_CHANGED';
      case PushNotificationType.systemErrorAlert:
        return 'SYSTEM_ERROR_ALERT';
      case PushNotificationType.userFeedbackReceived:
        return 'USER_FEEDBACK_RECEIVED';
      case PushNotificationType.attorneySelfReportedSession:
        return 'ATTORNEY_SELF_REPORTED_SESSION';
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
      case PushNotificationType.summarySubmittedForReview:
      case PushNotificationType.summaryApproved:
      case PushNotificationType.paymentAuthorizationFailed:
      case PushNotificationType.paymentReleasedToAttorney:
      case PushNotificationType.refundIssued:
      case PushNotificationType.attorneyAccountStatusChanged:
      case PushNotificationType.systemErrorAlert:
      case PushNotificationType.userFeedbackReceived:
      case PushNotificationType.attorneySelfReportedSession:
        return true;
      case PushNotificationType.paymentHoldCreated:
      case PushNotificationType.accountDeletedSuccessfully:
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
      case PushNotificationType.paymentReleasedToAttorney:
      case PushNotificationType.refundIssued:
      case PushNotificationType.paymentAuthorizationFailed:
        return true;
      default:
        return false;
    }
  }
}
