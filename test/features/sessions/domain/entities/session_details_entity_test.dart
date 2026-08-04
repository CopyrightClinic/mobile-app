import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_status.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/session_details_entity.dart';

SessionDetailsEntity _buildSessionDetails({
  required String scheduledDate,
  required String startTime,
  required String endTime,
  int durationMinutes = 30,
  SessionStatus status = SessionStatus.completed,
}) {
  final now = DateTime.now();
  return SessionDetailsEntity(
    id: 'session-1',
    scheduledDate: scheduledDate,
    startTime: startTime,
    endTime: endTime,
    durationMinutes: durationMinutes,
    status: status,
    summaryLocked: false,
    attorney: const SessionDetailsAttorneyEntity(id: 'attorney-1', name: 'Jane Attorney', email: 'jane@example.com'),
    user: const SessionDetailsUserEntity(id: 'user-1', email: 'user@example.com'),
    sessionRequest: const SessionRequestEntity(id: 'req-1', summary: 'summary'),
    createdAt: now,
    updatedAt: now,
    canCancel: true,
  );
}

void main() {
  group('SessionDetailsEntity.canRequestSummary (48-hour window)', () {
    test('is true once 1 hour has passed since session end and 48 hours have not elapsed', () {
      final sessionEnd = DateTime.now().subtract(const Duration(hours: 2));
      final iso = sessionEnd.toIso8601String();
      final time = iso.substring(11, 19);
      final session = _buildSessionDetails(scheduledDate: iso.split('T')[0], startTime: time, endTime: time, durationMinutes: 0);

      expect(session.canRequestSummary, isTrue);
    });

    test('is false again once the 48-hour deadline has passed (regression: used to be 15 days)', () {
      final sessionEnd = DateTime.now().subtract(const Duration(hours: 49));
      final iso = sessionEnd.toIso8601String();
      final time = iso.substring(11, 19);
      final session = _buildSessionDetails(scheduledDate: iso.split('T')[0], startTime: time, endTime: time, durationMinutes: 0);

      expect(session.canRequestSummary, isFalse);
    });
  });

  group('SessionDetailsEntity.summaryRequestDeadline', () {
    test('deadline is exactly 48 hours after the session end (not 15 days)', () {
      final session = _buildSessionDetails(scheduledDate: '2026-01-01', startTime: '10:00:00', endTime: '10:30:00', durationMinutes: 30);

      final expectedDeadline = DateTime.parse('2026-01-01T10:00:00').add(const Duration(minutes: 30)).add(const Duration(hours: 48));

      expect(session.summaryRequestDeadline, expectedDeadline);
    });
  });

  group('SessionDetailsEntity.endDateTime', () {
    test('parses scheduledDate + endTime directly', () {
      final session = _buildSessionDetails(scheduledDate: '2026-02-10', startTime: '09:00:00', endTime: '09:45:00', durationMinutes: 45);

      expect(session.endDateTime, DateTime.parse('2026-02-10T09:45:00'));
    });

    test('falls back to scheduledDateTime + durationMinutes when endTime is unparsable', () {
      final session = _buildSessionDetails(scheduledDate: '2026-02-10', startTime: '09:00:00', endTime: 'not-a-time', durationMinutes: 45);

      expect(session.endDateTime, session.scheduledDateTime.add(const Duration(minutes: 45)));
    });
  });

  group('SessionDetailsUserEntity nullable name', () {
    test('can be constructed without a name (regression: name used to be required)', () {
      const user = SessionDetailsUserEntity(id: 'user-1', email: 'user@example.com');

      expect(user.name, isNull);
    });

    test('equatable props still compare by id/name/email', () {
      const a = SessionDetailsUserEntity(id: 'user-1', name: 'A', email: 'a@example.com');
      const b = SessionDetailsUserEntity(id: 'user-1', name: 'A', email: 'a@example.com');
      const c = SessionDetailsUserEntity(id: 'user-1', email: 'a@example.com');

      expect(a, equals(b));
      expect(a == c, isFalse);
    });
  });
}
