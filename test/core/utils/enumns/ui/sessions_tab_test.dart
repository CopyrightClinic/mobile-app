import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/sessions_tab.dart';

void main() {
  group('SessionsTab.fromString', () {
    test('parses the pending tab', () {
      expect(SessionsTab.fromString('pending'), SessionsTab.pending);
    });

    test('parses the cancelled tab', () {
      expect(SessionsTab.fromString('cancelled'), SessionsTab.cancelled);
    });

    test('is case-insensitive', () {
      expect(SessionsTab.fromString('PENDING'), SessionsTab.pending);
      expect(SessionsTab.fromString('Cancelled'), SessionsTab.cancelled);
    });

    test('defaults to upcoming for an unknown value', () {
      expect(SessionsTab.fromString('unknown'), SessionsTab.upcoming);
    });
  });

  group('SessionsTab.apiValue', () {
    test('returns the expected api value for pending and cancelled', () {
      expect(SessionsTab.pending.apiValue, 'pending');
      expect(SessionsTab.cancelled.apiValue, 'cancelled');
    });
  });

  group('SessionsTab predicates', () {
    test('isPending is only true for the pending tab', () {
      expect(SessionsTab.pending.isPending, isTrue);
      expect(SessionsTab.upcoming.isPending, isFalse);
      expect(SessionsTab.completed.isPending, isFalse);
      expect(SessionsTab.cancelled.isPending, isFalse);
    });

    test('isCancelled is only true for the cancelled tab', () {
      expect(SessionsTab.cancelled.isCancelled, isTrue);
      expect(SessionsTab.upcoming.isCancelled, isFalse);
      expect(SessionsTab.completed.isCancelled, isFalse);
      expect(SessionsTab.pending.isCancelled, isFalse);
    });
  });
}
