import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/mixin/validator.dart';

class _ValidatorHost with Validator {}

void main() {
  late _ValidatorHost validator;

  setUp(() {
    validator = _ValidatorHost();
  });

  String identityTr(String key) => key;

  group('Validator.validateEmail', () {
    test('accepts plus-addressed emails (regression: "+" used to be rejected)', () {
      expect(validator.validateEmail('user+tag@example.com', identityTr), isNull);
    });

    test('still accepts a plain email', () {
      expect(validator.validateEmail('user@example.com', identityTr), isNull);
    });

    test('still rejects an empty value as required', () {
      expect(validator.validateEmail('', identityTr), 'emailIsRequired');
    });

    test('still rejects a malformed email', () {
      expect(validator.validateEmail('not-an-email', identityTr), 'pleaseEnterAValidEmail');
    });
  });
}
