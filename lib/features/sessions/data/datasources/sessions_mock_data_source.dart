import '../models/session_model.dart';

class SessionsMockDataSource {
  static List<SessionModel> getMockSessions() {
    final now = DateTime.now();

    return [
      SessionModel(
        id: '1',
        title: 'Legal Consultation',
        scheduledDate: now.add(const Duration(days: 2, hours: 14, minutes: 30)),
        durationMinutes: 30,
        price: 99.00,
        status: 'upcoming',
        description: 'Copyright consultation session',
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      SessionModel(
        id: '2',
        title: 'Legal Consultation',
        scheduledDate: now.add(const Duration(hours: 12)),
        durationMinutes: 30,
        price: 99.00,
        status: 'upcoming',
        description: 'Copyright consultation session',
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      SessionModel(
        id: '3',
        title: 'Legal Consultation',
        scheduledDate: now.subtract(const Duration(days: 7, hours: 14, minutes: 30)),
        durationMinutes: 30,
        price: 99.00,
        status: 'completed',
        description: 'Copyright consultation session',
        createdAt: now.subtract(const Duration(days: 10)),
      ),

      SessionModel(
        id: '4',
        title: 'Legal Consultation',
        scheduledDate: now.subtract(const Duration(days: 14, hours: 16)),
        durationMinutes: 30,
        price: 99.00,
        status: 'completed',
        description: 'Copyright consultation session',
        createdAt: now.subtract(const Duration(days: 17)),
      ),
    ];
  }
}
