enum SessionRequestStatus {
  pending,
  canceled;

  static SessionRequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return SessionRequestStatus.pending;
      case 'canceled':
        return SessionRequestStatus.canceled;
      default:
        return SessionRequestStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case SessionRequestStatus.pending:
        return 'pending';
      case SessionRequestStatus.canceled:
        return 'canceled';
    }
  }

  bool get isPending => this == SessionRequestStatus.pending;

  bool get isCanceled => this == SessionRequestStatus.canceled;
}
