import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/user_session_request_model.dart';

void main() {
  group('SessionRequestHoldModel.fromJson', () {
    test('parses sessionFee/processingFee/totalAmount from the new API shape', () {
      final model = SessionRequestHoldModel.fromJson({
        'sessionFee': 40,
        'processingFee': 5.5,
        'totalAmount': 45.5,
        'currency': 'usd',
        'status': 'held',
      });

      expect(model.sessionFee, 40.0);
      expect(model.processingFee, 5.5);
      expect(model.totalAmount, 45.5);
    });

    test('defaults each fee component to 0 when missing (regression: old required "amount" field is gone)', () {
      final model = SessionRequestHoldModel.fromJson({'currency': 'usd', 'status': 'held'});

      expect(model.sessionFee, 0.0);
      expect(model.processingFee, 0.0);
      expect(model.totalAmount, 0.0);
    });

    test('toEntity carries all three fee components through', () {
      final model = SessionRequestHoldModel.fromJson({
        'sessionFee': 40,
        'processingFee': 5,
        'totalAmount': 45,
        'currency': 'usd',
        'status': 'held',
      });
      final entity = model.toEntity();

      expect(entity.sessionFee, 40.0);
      expect(entity.processingFee, 5.0);
      expect(entity.totalAmount, 45.0);
      expect(entity.currency, 'usd');
      expect(entity.status, 'held');
    });
  });

  group('UserSessionRequestModel.fromJson', () {
    test('parses a full session request including a hold', () {
      final model = UserSessionRequestModel.fromJson({
        'id': 'req-1',
        'requestedDate': '2026-03-05',
        'startTime': '13:00:00',
        'endTime': '13:30:00',
        'status': 'pending',
        'isFreeSession': false,
        'hold': {'sessionFee': 40, 'processingFee': 5, 'totalAmount': 45, 'currency': 'usd', 'status': 'held'},
        'createdAt': '2026-03-01T00:00:00.000Z',
        'updatedAt': '2026-03-01T00:00:00.000Z',
      });

      expect(model.hold?.sessionFee, 40.0);
      expect(model.toEntity().formattedHoldAmount, '\$40.00');
    });

    test('parses a session request with no hold', () {
      final model = UserSessionRequestModel.fromJson({
        'id': 'req-1',
        'requestedDate': '2026-03-05',
        'startTime': '13:00:00',
        'endTime': '13:30:00',
        'status': 'pending',
        'createdAt': '2026-03-01T00:00:00.000Z',
        'updatedAt': '2026-03-01T00:00:00.000Z',
      });

      expect(model.hold, isNull);
      expect(model.isFreeSession, isFalse);
    });
  });
}
