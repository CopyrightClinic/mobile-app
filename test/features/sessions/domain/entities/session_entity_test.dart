import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_status.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/session_entity.dart';

SessionEntity _buildSession({
  required String scheduledDate,
  required String startTime,
  required String endTime,
  int durationMinutes = 30,
  SessionStatus status = SessionStatus.completed,
}) {
  final now = DateTime.now();
  return SessionEntity(
    id: 'session-1',
    scheduledDate: scheduledDate,
    startTime: startTime,
    endTime: endTime,
    durationMinutes: durationMinutes,
    status: status,
    attorney: const AttorneyEntity(id: 'attorney-1', name: 'Jane Attorney', email: 'jane@example.com'),
    createdAt: now,
    updatedAt: now,
    canCancel: true,
  );
}

void main() {
  group('SessionEntity.canRequestSummary (48-hour window)', () {
    test('is false right when the session ends (before the 1-hour lock lifts)', () {
      final now = DateTime.now();
      final sessionEnd = now.subtract(const Duration(minutes: 1));
      final session = _buildSession(
        scheduledDate: sessionEnd.toIso8601String().split('T')[0],
        startTime: '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:00',
        endTime: '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:00',
        durationMinutes: 0,
      );

      expect(session.canRequestSummary, isFalse);
    });

    test('is true once 1 hour has passed since session end and 48 hours have not elapsed', () {
      final sessionEnd = DateTime.now().subtract(const Duration(hours: 2));
      final session = _buildSession(
        scheduledDate: sessionEnd.toIso8601String().split('T')[0],
        startTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        endTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        durationMinutes: 0,
      );

      expect(session.canRequestSummary, isTrue);
    });

    test('is false again once the 48-hour deadline has passed (regression: used to be 15 days)', () {
      final sessionEnd = DateTime.now().subtract(const Duration(hours: 49));
      final session = _buildSession(
        scheduledDate: sessionEnd.toIso8601String().split('T')[0],
        startTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        endTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        durationMinutes: 0,
      );

      expect(session.canRequestSummary, isFalse);
    });

    test('is false for sessions that are not completed, regardless of timing', () {
      final sessionEnd = DateTime.now().subtract(const Duration(hours: 2));
      final session = _buildSession(
        scheduledDate: sessionEnd.toIso8601String().split('T')[0],
        startTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        endTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        durationMinutes: 0,
        status: SessionStatus.upcoming,
      );

      expect(session.canRequestSummary, isFalse);
    });
  });

  group('SessionEntity.summaryRequestDeadline / hasSummaryRequestExpired', () {
    test('deadline is exactly 48 hours after the session end (not 15 days)', () {
      final session = _buildSession(scheduledDate: '2026-01-01', startTime: '10:00:00', endTime: '10:30:00', durationMinutes: 30);

      final expectedDeadline = DateTime.parse('2026-01-01T10:00:00').add(const Duration(minutes: 30)).add(const Duration(hours: 48));

      expect(session.summaryRequestDeadline, expectedDeadline);
    });

    test('hasSummaryRequestExpired is true once now is at/after the deadline', () {
      final sessionEnd = DateTime.now().subtract(const Duration(hours: 50));
      final session = _buildSession(
        scheduledDate: sessionEnd.toIso8601String().split('T')[0],
        startTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        endTime:
            '${sessionEnd.hour.toString().padLeft(2, '0')}:${sessionEnd.minute.toString().padLeft(2, '0')}:${sessionEnd.second.toString().padLeft(2, '0')}',
        durationMinutes: 0,
      );

      expect(session.hasSummaryRequestExpired, isTrue);
    });

    test('hasSummaryRequestExpired is false for a session that is not completed', () {
      final session = _buildSession(
        scheduledDate: '2020-01-01',
        startTime: '10:00:00',
        endTime: '10:30:00',
        status: SessionStatus.upcoming,
      );

      expect(session.hasSummaryRequestExpired, isFalse);
    });
  });

  group('SessionEntity.endDateTime', () {
    test('parses scheduledDate + endTime directly', () {
      final session = _buildSession(scheduledDate: '2026-02-10', startTime: '09:00:00', endTime: '09:45:00', durationMinutes: 45);

      expect(session.endDateTime, DateTime.parse('2026-02-10T09:45:00'));
    });

    test('falls back to scheduledDateTime + durationMinutes when endTime is unparsable', () {
      final session = _buildSession(scheduledDate: '2026-02-10', startTime: '09:00:00', endTime: 'not-a-time', durationMinutes: 45);

      expect(session.endDateTime, session.scheduledDateTime.add(const Duration(minutes: 45)));
    });
  });
}
