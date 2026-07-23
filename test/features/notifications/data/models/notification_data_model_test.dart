import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/api/notifications_enums.dart';
import 'package:copyright_clinic_flutter/features/notifications/data/models/notification_data_model.dart';

void main() {
  group('NotificationDataModel.fromJson dispatch', () {
    test('sessionCancelled routes to SessionNotificationData (new case added alongside the other session types)', () {
      final data = NotificationDataModel.fromJson({'sessionId': 'session-1', 'reason': 'payment hold released'}, NotificationType.sessionCancelled);

      expect(data, isA<SessionNotificationData>());
      expect((data as SessionNotificationData).sessionId, 'session-1');
    });

    test('refundIssued still routes to PaymentNotificationData', () {
      final data = NotificationDataModel.fromJson({'refundId': 'refund-1'}, NotificationType.refundIssued);

      expect(data, isA<PaymentNotificationData>());
    });

    test('returns EmptyNotificationData when json is null, regardless of type', () {
      final data = NotificationDataModel.fromJson(null, NotificationType.sessionCancelled);

      expect(data, isA<EmptyNotificationData>());
    });
  });

  group('SessionNotificationData.fromJson fee extraction', () {
    test('reads totalFee/extensionFee out of a nested "fees" object when present', () {
      final data = SessionNotificationData.fromJson({
        'sessionId': 'session-1',
        'fees': {'totalFee': 45, 'sessionFee': 40},
      });

      expect(data.totalFee, '45');
      expect(data.extensionFee, '40');
    });

    test('falls back to top-level totalFee/extensionFee when there is no "fees" object', () {
      final data = SessionNotificationData.fromJson({'sessionId': 'session-1', 'totalFee': '45', 'extensionFee': '10'});

      expect(data.totalFee, '45');
      expect(data.extensionFee, '10');
    });
  });
}
