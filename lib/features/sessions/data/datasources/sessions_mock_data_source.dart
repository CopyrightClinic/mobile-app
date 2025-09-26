import '../models/session_model.dart';
import '../../../../core/constants/app_strings.dart';

class SessionsMockDataSource {
  static List<SessionModel> getMockSessions() {
    final now = DateTime.now();

    return [
      // SessionModel(
      //   id: '1',
      //   title: AppStrings.legalConsultation,
      //   scheduledDate: now.add(const Duration(days: 2, hours: 14, minutes: 30)),
      //   durationMinutes: 30,
      //   price: 99.00,
      //   status: 'upcoming',
      //   description: AppStrings.copyrightConsultationSession,
      //   createdAt: now.subtract(const Duration(days: 5)),
      // ),

      // SessionModel(
      //   id: '2',
      //   title: AppStrings.legalConsultation,
      //   scheduledDate: now.add(const Duration(hours: 12)),
      //   durationMinutes: 30,
      //   price: 99.00,
      //   status: 'upcoming',
      //   description: AppStrings.copyrightConsultationSession,
      //   createdAt: now.subtract(const Duration(days: 3)),
      // ),

      // SessionModel(
      //   id: '3',
      //   title: AppStrings.legalConsultation,
      //   scheduledDate: now.subtract(const Duration(days: 7, hours: 14, minutes: 30)),
      //   durationMinutes: 30,
      //   price: 99.00,
      //   status: 'completed',
      //   description: AppStrings.copyrightConsultationSession,
      //   createdAt: now.subtract(const Duration(days: 10)),
      // ),

      // SessionModel(
      //   id: '4',
      //   title: AppStrings.legalConsultation,
      //   scheduledDate: now.subtract(const Duration(days: 14, hours: 16)),
      //   durationMinutes: 30,
      //   price: 99.00,
      //   status: 'completed',
      //   description: AppStrings.copyrightConsultationSession,
      //   createdAt: now.subtract(const Duration(days: 17)),
      // ),
    ];
  }
}
