import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_request_status.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/user_session_request_entity.dart';

UserSessionRequestEntity _buildEntity({
  required String startTime,
  required String endTime,
  SessionRequestStatus status = SessionRequestStatus.pending,
  SessionRequestHoldEntity? hold,
}) {
  final now = DateTime.now();
  return UserSessionRequestEntity(
    id: 'req-1',
    requestedDate: '2026-07-10',
    startTime: startTime,
    endTime: endTime,
    status: status,
    isFreeSession: false,
    hold: hold,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

void main() {
  group('UserSessionRequestEntity', () {
    test('isPending/isCanceled reflect the underlying status', () {
      final pending = _buildEntity(startTime: '10:00:00', endTime: '10:30:00');
      final canceled = _buildEntity(startTime: '10:00:00', endTime: '10:30:00', status: SessionRequestStatus.canceled);

      expect(pending.isPending, isTrue);
      expect(pending.isCanceled, isFalse);
      expect(canceled.isPending, isFalse);
      expect(canceled.isCanceled, isTrue);
    });

    test('formattedDuration reports hours and minutes together', () {
      final entity = _buildEntity(startTime: '09:00:00', endTime: '10:30:00');
      expect(entity.formattedDuration, '1 hour 30 minutes');
    });

    test('formattedDuration reports hours only when minutes are zero', () {
      final entity = _buildEntity(startTime: '09:00:00', endTime: '11:00:00');
      expect(entity.formattedDuration, '2 hours');
    });

    test('formattedDuration reports minutes only when under an hour', () {
      final entity = _buildEntity(startTime: '09:00:00', endTime: '09:15:00');
      expect(entity.formattedDuration, '15 minutes');
    });

    test('formattedDuration falls back to empty string on unparsable times', () {
      final entity = _buildEntity(startTime: 'not-a-time', endTime: 'also-not-a-time');
      expect(entity.formattedDuration, '');
    });

    test('scheduledDateTime parses the requested date and start time', () {
      final entity = _buildEntity(startTime: '09:00:00', endTime: '09:15:00');
      expect(entity.scheduledDateTime, DateTime.parse('2026-07-10T09:00:00'));
    });

    test('scheduledDateTime falls back instead of throwing on bad input', () {
      final entity = _buildEntity(startTime: 'not-a-time', endTime: '09:15:00');
      expect(() => entity.scheduledDateTime, returnsNormally);
    });

    test('formattedHoldAmount defaults to zero when there is no hold', () {
      final entity = _buildEntity(startTime: '09:00:00', endTime: '09:15:00');
      expect(entity.formattedHoldAmount, '\$0.00');
    });

    test('formattedHoldAmount reflects the hold amount when present', () {
      final entity = _buildEntity(
        startTime: '09:00:00',
        endTime: '09:15:00',
        hold: const SessionRequestHoldEntity(
          sessionFee: 12.3,
          processingFee: 0,
          totalAmount: 12.3,
          currency: 'usd',
          status: 'held',
        ),
      );
      expect(entity.formattedHoldAmount, '\$12.30');
    });
  });
}
