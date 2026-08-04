import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/cancel_session_request_response_model.dart';

void main() {
  group('CancelSessionRequestResponseModel', () {
    test('fromJson parses the message field', () {
      final model = CancelSessionRequestResponseModel.fromJson({'message': 'Request cancelled successfully'});
      expect(model.message, 'Request cancelled successfully');
    });

    test('fromJson tolerates a missing message field', () {
      final model = CancelSessionRequestResponseModel.fromJson(<String, dynamic>{});
      expect(model.message, isNull);
    });

    test('toJson round-trips the message field', () {
      const model = CancelSessionRequestResponseModel(message: 'Cancelled');
      expect(model.toJson(), {'message': 'Cancelled'});
    });

    test('toEntity carries the message across', () {
      const model = CancelSessionRequestResponseModel(message: 'Cancelled');
      final entity = model.toEntity();
      expect(entity.message, 'Cancelled');
    });

    test('toEntity carries a null message across', () {
      const model = CancelSessionRequestResponseModel();
      final entity = model.toEntity();
      expect(entity.message, isNull);
    });
  });
}
