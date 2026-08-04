import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/core/utils/session_datetime_utils.dart';

// easy_localization's `.tr()` is not initialized in a plain unit test, so it
// falls back to returning the translation key itself (e.g. "to", "today")
// rather than throwing. Assertions below match on that fallback text.
void main() {
  group('SessionDateTimeUtils.formatSessionDate', () {
    test('uses the explicit endDateTime when provided instead of the default 30-minute slot', () {
      final start = DateTime(2026, 3, 5, 9, 0);
      final end = DateTime(2026, 3, 5, 10, 15);

      final result = SessionDateTimeUtils.formatSessionDate(start, endDateTime: end);

      expect(result, contains('9:00 AM'));
      expect(result, contains('10:15 AM'));
      expect(result, isNot(contains('9:30 AM')));
    });

    test('falls back to start + 30 minutes when endDateTime is not provided (unchanged default behavior)', () {
      final start = DateTime(2026, 3, 5, 9, 0);

      final result = SessionDateTimeUtils.formatSessionDate(start);

      expect(result, contains('9:00 AM'));
      expect(result, contains('9:30 AM'));
    });

    test('labels the current day using the "today" key', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 9, 0);

      final result = SessionDateTimeUtils.formatSessionDate(today);

      expect(result, startsWith('today,'));
    });
  });
}
