import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/network/exception/custom_exception.dart';

void main() {
  group('CustomException.toString', () {
    test('returns the raw message instead of the default "Instance of ..." (regression fix)', () {
      final exception = CustomException(message: 'Invalid coupon code');

      expect(exception.toString(), 'Invalid coupon code');
      expect('$exception', 'Invalid coupon code');
    });

    test('defaults statusCode to 500 when not provided', () {
      final exception = CustomException(message: 'boom');

      expect(exception.statusCode, 500);
    });
  });
}
