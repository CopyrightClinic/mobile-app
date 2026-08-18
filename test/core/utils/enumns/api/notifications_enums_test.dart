import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/api/notifications_enums.dart';

void main() {
  group('NotificationType.fromString', () {
    test('maps PAYMENT_HOLD_RELEASED to sessionCancelled (new mapping)', () {
      expect(NotificationType.fromString('PAYMENT_HOLD_RELEASED'), NotificationType.sessionCancelled);
    });

    test('is case-insensitive', () {
      expect(NotificationType.fromString('payment_hold_released'), NotificationType.sessionCancelled);
    });

    test('falls back to sessionReminder for unknown values', () {
      expect(NotificationType.fromString('SOMETHING_UNKNOWN'), NotificationType.sessionReminder);
    });

    test('does NOT map a literal "SESSION_CANCELLED" string to sessionCancelled', () {
      // The API represents a cancelled session as PAYMENT_HOLD_RELEASED, not SESSION_CANCELLED.
      // If the backend ever sends this literal string it silently falls back to sessionReminder.
      expect(NotificationType.fromString('SESSION_CANCELLED'), NotificationType.sessionReminder);
    });
  });

  group('NotificationType.toApiString', () {
    test('sessionCancelled serializes back to PAYMENT_HOLD_RELEASED', () {
      expect(NotificationType.sessionCancelled.toApiString(), 'PAYMENT_HOLD_RELEASED');
    });

    test('round-trips through fromString/toApiString for every enum value', () {
      for (final type in NotificationType.values) {
        expect(NotificationType.fromString(type.toApiString()), type);
      }
    });
  });
}
