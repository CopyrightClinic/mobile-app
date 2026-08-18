import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/book_session_request_model.dart';

void main() {
  group('BookSessionRequestModel', () {
    test('toJson includes the originalInput field alongside the other booking params', () {
      const model = BookSessionRequestModel(
        stripePaymentMethodId: 'pm_123',
        couponCode: 'SAVE10',
        date: '2026-07-10',
        slot: BookSessionSlotModel(start: '10:00', end: '10:30'),
        summary: 'Copyright question',
        originalInput: 'Can I use this logo commercially?',
      );

      final json = model.toJson();

      expect(json['originalInput'], 'Can I use this logo commercially?');
      expect(json['summary'], 'Copyright question');
      expect(json['slot'], isA<BookSessionSlotModel>());
    });

    test('fromJson requires the originalInput field', () {
      final json = {
        'stripePaymentMethodId': 'pm_123',
        'date': '2026-07-10',
        'slot': {'start': '10:00', 'end': '10:30'},
        'summary': 'Copyright question',
        'originalInput': 'Can I use this logo commercially?',
      };

      final model = BookSessionRequestModel.fromJson(json);

      expect(model.originalInput, 'Can I use this logo commercially?');
      expect(model.couponCode, isNull);
    });

    test('fromJson throws when originalInput is missing', () {
      final json = {
        'stripePaymentMethodId': 'pm_123',
        'date': '2026-07-10',
        'slot': {'start': '10:00', 'end': '10:30'},
        'summary': 'Copyright question',
      };

      expect(() => BookSessionRequestModel.fromJson(json), throwsA(anything));
    });
  });
}
