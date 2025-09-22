import '../../../constants/app_strings.dart';

enum SessionStatus {
  upcoming,
  completed,
  cancelled;

  static SessionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return SessionStatus.upcoming;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.upcoming;
    }
  }

  String get displayName {
    switch (this) {
      case SessionStatus.upcoming:
        return AppStrings.upcomingStatus;
      case SessionStatus.completed:
        return AppStrings.completedStatus;
      case SessionStatus.cancelled:
        return AppStrings.cancelledStatus;
    }
  }

  String get apiValue {
    switch (this) {
      case SessionStatus.upcoming:
        return 'upcoming';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get isUpcoming => this == SessionStatus.upcoming;

  bool get isCompleted => this == SessionStatus.completed;

  bool get isCancelled => this == SessionStatus.cancelled;
}
