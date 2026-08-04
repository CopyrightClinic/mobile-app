import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/features/zoom/data/models/zoom_meeting_credentials_model.dart';

void main() {
  group('ZoomMeetingCredentialsModel', () {
    test('fromJson allows a null userName', () {
      final json = {'signature': 'sig', 'meetingNumber': '123456789', 'password': 'pass', 'role': 0, 'userName': null, 'userEmail': null};

      final model = ZoomMeetingCredentialsModel.fromJson(json);

      expect(model.userName, isNull);
      expect(model.signature, 'sig');
    });

    test('fromJson tolerates a missing userName field entirely', () {
      final json = {'signature': 'sig', 'meetingNumber': '123456789', 'password': 'pass'};

      final model = ZoomMeetingCredentialsModel.fromJson(json);

      expect(model.userName, isNull);
    });

    test('fromJson parses a present userName', () {
      final json = {'signature': 'sig', 'meetingNumber': '123456789', 'password': 'pass', 'userName': 'Jane Doe'};

      final model = ZoomMeetingCredentialsModel.fromJson(json);

      expect(model.userName, 'Jane Doe');
    });

    test('toEntity carries a null userName through to the entity', () {
      const model = ZoomMeetingCredentialsModel(signature: 'sig', meetingNumber: '123456789', password: 'pass', userName: null);

      final entity = model.toEntity();

      expect(entity.userName, isNull);
    });
  });
}
