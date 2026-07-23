import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/session_details_model.dart';

void main() {
  group('SessionDetailsUserModel.fromJson (nullable name)', () {
    test('parses when name is present', () {
      final model = SessionDetailsUserModel.fromJson({'id': 'user-1', 'name': 'Jane', 'email': 'jane@example.com'});

      expect(model.name, 'Jane');
    });

    test('parses when name is null (regression: name used to be a required non-null field)', () {
      final model = SessionDetailsUserModel.fromJson({'id': 'user-1', 'name': null, 'email': 'jane@example.com'});

      expect(model.name, isNull);
      expect(model.toEntity().name, isNull);
    });

    test('parses when name key is entirely absent from the payload', () {
      final model = SessionDetailsUserModel.fromJson({'id': 'user-1', 'email': 'jane@example.com'});

      expect(model.name, isNull);
    });
  });
}
