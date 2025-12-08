import '../models/session_model.dart';
import '../../../../core/constants/app_strings.dart';

class SessionsMockDataSource {
  static List<SessionModel> getMockSessions() {
    final now = DateTime.now();

    return [
      SessionModel(
        id: '1',
        scheduledDate: now.add(const Duration(days: 2)).toIso8601String().split('T')[0],
        startTime: '14:30',
        endTime: '15:00',
        durationMinutes: 30,
        status: 'upcoming',
        summary: AppStrings.copyrightConsultationSession,
        attorney: const AttorneyModel(id: 'attorney-1', name: 'Sarah Johnson', email: 'sarah.johnson@example.com'),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),

      SessionModel(
        id: '2',
        scheduledDate: now.add(const Duration(hours: 12)).toIso8601String().split('T')[0],
        startTime: '12:00',
        endTime: '12:30',
        durationMinutes: 30,
        status: 'upcoming',
        summary: AppStrings.copyrightConsultationSession,
        attorney: const AttorneyModel(id: 'attorney-2', name: 'Michael Davis', email: 'michael.davis@example.com'),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),

      SessionModel(
        id: '3',
        scheduledDate: now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0],
        startTime: '14:30',
        endTime: '15:00',
        durationMinutes: 30,
        status: 'completed',
        summary: AppStrings.copyrightConsultationSession,
        rating: 4.5,
        review: 'Great session, very helpful advice.',
        attorney: const AttorneyModel(id: 'attorney-1', name: 'Sarah Johnson', email: 'sarah.johnson@example.com'),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),

      SessionModel(
        id: '4',
        scheduledDate: now.subtract(const Duration(days: 14)).toIso8601String().split('T')[0],
        startTime: '16:00',
        endTime: '16:30',
        durationMinutes: 30,
        status: 'completed',
        summary: AppStrings.copyrightConsultationSession,
        rating: 5.0,
        review: 'Excellent consultation, highly recommend.',
        attorney: const AttorneyModel(id: 'attorney-3', name: 'Jennifer Wilson', email: 'jennifer.wilson@example.com'),
        createdAt: now.subtract(const Duration(days: 17)),
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }
}
