import '../../../constants/app_strings.dart';

enum SessionsTab {
  upcoming,
  completed,
  pending,
  cancelled;

  static SessionsTab fromString(String tab) {
    switch (tab.toLowerCase()) {
      case 'upcoming':
        return SessionsTab.upcoming;
      case 'completed':
        return SessionsTab.completed;
      case 'pending':
        return SessionsTab.pending;
      case 'cancelled':
        return SessionsTab.cancelled;
      default:
        return SessionsTab.upcoming;
    }
  }

  String get displayName {
    switch (this) {
      case SessionsTab.upcoming:
        return AppStrings.upcoming;
      case SessionsTab.completed:
        return AppStrings.completed;
      case SessionsTab.pending:
        return AppStrings.pending;
      case SessionsTab.cancelled:
        return AppStrings.cancelled;
    }
  }

  String get apiValue {
    switch (this) {
      case SessionsTab.upcoming:
        return 'upcoming';
      case SessionsTab.completed:
        return 'completed';
      case SessionsTab.pending:
        return 'pending';
      case SessionsTab.cancelled:
        return 'cancelled';
    }
  }

  bool get isUpcoming => this == SessionsTab.upcoming;

  bool get isCompleted => this == SessionsTab.completed;

  bool get isPending => this == SessionsTab.pending;

  bool get isCancelled => this == SessionsTab.cancelled;
}
