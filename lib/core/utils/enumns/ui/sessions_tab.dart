import '../../../constants/app_strings.dart';

enum SessionsTab {
  upcoming,
  completed;

  static SessionsTab fromString(String tab) {
    switch (tab.toLowerCase()) {
      case 'upcoming':
        return SessionsTab.upcoming;
      case 'completed':
        return SessionsTab.completed;
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
    }
  }

  String get apiValue {
    switch (this) {
      case SessionsTab.upcoming:
        return 'upcoming';
      case SessionsTab.completed:
        return 'completed';
    }
  }

  bool get isUpcoming => this == SessionsTab.upcoming;

  bool get isCompleted => this == SessionsTab.completed;
}
