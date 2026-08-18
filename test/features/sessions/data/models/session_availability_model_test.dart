import 'package:flutter_test/flutter_test.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/session_availability_model.dart';
import 'package:copyright_clinic_flutter/core/utils/session_datetime_utils.dart';

// Reproduces the timezone bug: the backend sends UTC instants (e.g. the UTC
// representation of local midnight for a given day). Without `.toLocal()`
// in toEntity(), reading `.day`/`.month`/`.year` off that value yields the
// UTC calendar date, which is one day behind the intended local date for any
// machine with a positive UTC offset (e.g. Asia/Karachi, UTC+5).
//
// This test is offset-independent: it derives the UTC string from a local
// DateTime using `.toUtc()`, so it fails pre-fix on any non-UTC+0 machine
// and passes post-fix everywhere.
void main() {
  group('AvailabilityDayModel.toEntity', () {
    test('recovers the original local calendar day from a UTC date string', () {
      final localDay = DateTime(2026, 8, 1);
      final utcDateString = localDay.toUtc().toIso8601String();

      final model = AvailabilityDayModel(date: utcDateString, weekday: 'Saturday', slots: const []);
      final entity = model.toEntity();

      expect(entity.date.isUtc, isFalse);
      expect(entity.date.year, localDay.year);
      expect(entity.date.month, localDay.month);
      expect(entity.date.day, localDay.day);
    });

    test('submits the correct date string to the booking API (regression for "past date" rejection)', () {
      final localDay = DateTime(2026, 8, 1);
      final utcDateString = localDay.toUtc().toIso8601String();

      final model = AvailabilityDayModel(date: utcDateString, weekday: 'Saturday', slots: const []);
      final entity = model.toEntity();

      expect(SessionDateTimeUtils.formatDateToIso(entity.date), '2026-08-01');
    });
  });

  group('TimeSlotModel.toEntity', () {
    test('converts start/end to local time', () {
      final localStart = DateTime(2026, 8, 1, 9, 0);
      final localEnd = DateTime(2026, 8, 1, 9, 30);

      final model = TimeSlotModel(start: localStart.toUtc().toIso8601String(), end: localEnd.toUtc().toIso8601String());
      final entity = model.toEntity();

      expect(entity.start.isUtc, isFalse);
      expect(entity.start, localStart);
      expect(entity.end, localEnd);
    });
  });
}
