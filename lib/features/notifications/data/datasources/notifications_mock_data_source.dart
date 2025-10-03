import '../../../../core/constants/app_strings.dart';
import '../models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsMockDataSource {
  static List<NotificationModel> getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: AppStrings.yourSessionSummaryIsReady,
        description: AppStrings.sessionSummaryDescription,
        type: NotificationType.sessionSummary,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        metadata: {'sessionId': 'session_123', 'sessionDate': '2024-05-29'},
      ),
      NotificationModel(
        id: '2',
        title: AppStrings.yourSessionStartsIn1Hour,
        description: AppStrings.sessionStartsDescription,
        type: NotificationType.sessionReminder,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 24)),
        metadata: {'sessionId': 'session_456', 'sessionTime': '3:00 PM'},
      ),
    ];
  }
}
