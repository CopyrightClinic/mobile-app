enum SummaryApprovalStatus {
  notRequested,
  adminApprovalPending,
  attorneyReviewPending,
  readyForUser;

  static SummaryApprovalStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'not_requested':
        return SummaryApprovalStatus.notRequested;
      case 'admin_approval_pending':
        return SummaryApprovalStatus.adminApprovalPending;
      case 'attorney_review_pending':
        return SummaryApprovalStatus.attorneyReviewPending;
      case 'ready_for_user':
        return SummaryApprovalStatus.readyForUser;
      default:
        return SummaryApprovalStatus.notRequested;
    }
  }

  String get apiValue {
    switch (this) {
      case SummaryApprovalStatus.notRequested:
        return 'not_requested';
      case SummaryApprovalStatus.adminApprovalPending:
        return 'admin_approval_pending';
      case SummaryApprovalStatus.attorneyReviewPending:
        return 'attorney_review_pending';
      case SummaryApprovalStatus.readyForUser:
        return 'ready_for_user';
    }
  }

  bool get isNotRequested => this == SummaryApprovalStatus.notRequested;

  bool get isAdminApprovalPending => this == SummaryApprovalStatus.adminApprovalPending;

  bool get isAttorneyReviewPending => this == SummaryApprovalStatus.attorneyReviewPending;

  bool get isReadyForUser => this == SummaryApprovalStatus.readyForUser;
}
