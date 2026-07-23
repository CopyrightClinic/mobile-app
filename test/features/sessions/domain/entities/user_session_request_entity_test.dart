import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_request_status.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/user_session_request_entity.dart';

UserSessionRequestEntity _buildRequest({
  required String requestedDate,
  required String startTime,
  required String endTime,
  SessionRequestHoldEntity? hold,
}) {
  final now = DateTime.now();
  return UserSessionRequestEntity(
    id: 'request-1',
    requestedDate: requestedDate,
    startTime: startTime,
    endTime: endTime,
    status: SessionRequestStatus.pending,
    isFreeSession: false,
    hold: hold,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('UserSessionRequestEntity.endDateTime', () {
    test('parses requestedDate + endTime directly', () {
      final request = _buildRequest(requestedDate: '2026-03-05', startTime: '13:00:00', endTime: '13:30:00');

      expect(request.endDateTime, DateTime.parse('2026-03-05T13:30:00'));
    });

    test('falls back to scheduledDateTime when endTime is unparsable', () {
      final request = _buildRequest(requestedDate: '2026-03-05', startTime: '13:00:00', endTime: 'garbage');

      expect(request.endDateTime, request.scheduledDateTime);
    });
  });

  group('SessionRequestHoldEntity (sessionFee/processingFee/totalAmount split)', () {
    test('exposes the three fee components separately instead of a single amount', () {
      const hold = SessionRequestHoldEntity(sessionFee: 40, processingFee: 5, totalAmount: 45, currency: 'usd', status: 'held');

      expect(hold.sessionFee, 40);
      expect(hold.processingFee, 5);
      expect(hold.totalAmount, 45);
    });

    test('equality/props include all fee fields', () {
      const a = SessionRequestHoldEntity(sessionFee: 40, processingFee: 5, totalAmount: 45, currency: 'usd', status: 'held');
      const b = SessionRequestHoldEntity(sessionFee: 40, processingFee: 5, totalAmount: 45, currency: 'usd', status: 'held');
      const c = SessionRequestHoldEntity(sessionFee: 41, processingFee: 5, totalAmount: 46, currency: 'usd', status: 'held');

      expect(a, equals(b));
      expect(a == c, isFalse);
    });
  });

  group('UserSessionRequestEntity.formattedHoldAmount', () {
    test('formats using hold.sessionFee (regression: used to read hold.amount, a field that no longer exists)', () {
      final request = _buildRequest(
        requestedDate: '2026-03-05',
        startTime: '13:00:00',
        endTime: '13:30:00',
        hold: const SessionRequestHoldEntity(sessionFee: 40, processingFee: 5, totalAmount: 45, currency: 'usd', status: 'held'),
      );

      expect(request.formattedHoldAmount, '\$40.00');
    });

    test('defaults to \$0.00 when there is no hold', () {
      final request = _buildRequest(requestedDate: '2026-03-05', startTime: '13:00:00', endTime: '13:30:00');

      expect(request.formattedHoldAmount, '\$0.00');
    });
  });
}
