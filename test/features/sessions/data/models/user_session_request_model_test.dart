import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_request_status.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/user_session_request_model.dart';

void main() {
  group('UserSessionRequestModel.fromJson', () {
    test('parses a full pending request payload', () {
      final json = {
        'id': 'req-1',
        'requestedDate': '2026-07-10',
        'startTime': '10:00:00',
        'endTime': '10:30:00',
        'status': 'pending',
        'summary': 'Copyright question',
        'isFreeSession': true,
        'couponCode': 'SAVE10',
        'hold': {'amount': 25.5, 'currency': 'usd', 'status': 'held'},
        'expiresAt': '2026-07-11T00:00:00.000Z',
        'canceledAt': null,
        'cancellationReason': null,
        'createdAt': '2026-07-01T00:00:00.000Z',
        'updatedAt': '2026-07-01T00:00:00.000Z',
      };

      final model = UserSessionRequestModel.fromJson(json);

      expect(model.id, 'req-1');
      expect(model.isFreeSession, isTrue);
      expect(model.hold?.amount, 25.5);
      expect(model.hold?.currency, 'usd');
      expect(model.canceledAt, isNull);
    });

    test('defaults isFreeSession to false and allows a missing hold', () {
      final json = {
        'id': 'req-2',
        'requestedDate': '2026-07-10',
        'startTime': '10:00:00',
        'endTime': '10:30:00',
        'status': 'canceled',
        'createdAt': '2026-07-01T00:00:00.000Z',
        'updatedAt': '2026-07-01T00:00:00.000Z',
      };

      final model = UserSessionRequestModel.fromJson(json);

      expect(model.isFreeSession, isFalse);
      expect(model.hold, isNull);
      expect(model.summary, isNull);
    });
  });

  group('UserSessionRequestModel.toEntity', () {
    test('maps status string to the SessionRequestStatus enum', () {
      final pendingModel = UserSessionRequestModel(
        id: 'req-1',
        requestedDate: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        status: 'pending',
        isFreeSession: false,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

      final canceledModel = UserSessionRequestModel(
        id: 'req-2',
        requestedDate: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        status: 'canceled',
        isFreeSession: false,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

      expect(pendingModel.toEntity().status, SessionRequestStatus.pending);
      expect(pendingModel.toEntity().isPending, isTrue);
      expect(canceledModel.toEntity().status, SessionRequestStatus.canceled);
      expect(canceledModel.toEntity().isCanceled, isTrue);
    });

    test('carries the hold entity through when present', () {
      final model = UserSessionRequestModel(
        id: 'req-1',
        requestedDate: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        status: 'pending',
        isFreeSession: false,
        hold: const SessionRequestHoldModel(amount: 10, currency: 'usd', status: 'held'),
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

      final entity = model.toEntity();

      expect(entity.hold?.amount, 10);
      expect(entity.hold?.currency, 'usd');
      expect(entity.formattedHoldAmount, '\$10.00');
    });
  });
}
