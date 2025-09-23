import 'package:easy_localization/easy_localization.dart';
import '../constants/app_strings.dart';

class SessionDateTimeUtils {
  SessionDateTimeUtils._();

  static final RegExp _isoTimeSlotRegex = RegExp(
    r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z?)-(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z?)',
  );
  static final RegExp _fallbackTimeSlotRegex = RegExp(r'^(.+)-(\d{4}-.+)$');

  static const int sessionDurationMinutes = 30;

  static String formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    final startTime = DateFormat('h:mm A').format(date);
    final endTime = DateFormat('h:mm A').format(date.add(const Duration(minutes: sessionDurationMinutes)));
    final timeRange = '$startTime ${AppStrings.to.tr()} $endTime';

    if (sessionDate == today) {
      final dateStr = DateFormat('MMM d').format(date);
      return '${AppStrings.today.tr()}, $dateStr – $timeRange';
    } else {
      final dateStr = DateFormat('EEEE, MMM d').format(date);
      return '$dateStr – $timeRange';
    }
  }

  static String formatSessionDateTime(DateTime date, String? timeSlot) {
    final dayName = DateFormat('EEEE').format(date);
    final monthDay = DateFormat('MMM d').format(date);

    final timeRange = _formatTimeRange(date, timeSlot);
    return '$dayName, $monthDay – $timeRange';
  }

  static String formatCancellationDeadline(DateTime sessionDate) {
    final deadline = sessionDate.subtract(const Duration(hours: 24));
    final dateStr = DateFormat('dd/MM/yy').format(deadline);
    final timeStr = DateFormat('h:mm A').format(deadline);
    return '$dateStr, $timeStr';
  }

  static String formatDateToIso(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  static String createTimeSlotKey(DateTime start, DateTime end) {
    return '${start.toIso8601String()}-${end.toIso8601String()}';
  }

  static TimeSlotParsed? parseTimeSlot(String timeSlot) {
    final isoMatch = _isoTimeSlotRegex.firstMatch(timeSlot);
    if (isoMatch != null && isoMatch.groupCount == 2) {
      return TimeSlotParsed(startTimeIso: isoMatch.group(1)!, endTimeIso: isoMatch.group(2)!);
    }

    final fallbackMatch = _fallbackTimeSlotRegex.firstMatch(timeSlot);
    if (fallbackMatch != null && fallbackMatch.groupCount == 2) {
      return TimeSlotParsed(startTimeIso: fallbackMatch.group(1)!, endTimeIso: fallbackMatch.group(2)!);
    }

    return null;
  }

  static String parseTimeSlotToTimeRange(DateTime fallbackDate, String? timeSlot) {
    if (timeSlot == null || timeSlot.isEmpty) {
      return _formatDefaultTimeRange(fallbackDate);
    }

    try {
      final isoMatch = _isoTimeSlotRegex.firstMatch(timeSlot);
      if (isoMatch != null && isoMatch.groupCount == 2) {
        final startDateTime = DateTime.parse(isoMatch.group(1)!);
        final endDateTime = DateTime.parse(isoMatch.group(2)!);

        final startTime = DateFormat('h:mm A').format(startDateTime);
        final endTime = DateFormat('h:mm A').format(endDateTime);
        return '$startTime ${AppStrings.to.tr()} $endTime';
      }
    } catch (e) {}

    return _formatDefaultTimeRange(fallbackDate);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static String _formatTimeRange(DateTime date, String? timeSlot) {
    if (timeSlot != null && timeSlot.isNotEmpty) {
      try {
        final isoMatch = _isoTimeSlotRegex.firstMatch(timeSlot);
        if (isoMatch != null && isoMatch.groupCount == 2) {
          final startDateTime = DateTime.parse(isoMatch.group(1)!);
          final endDateTime = DateTime.parse(isoMatch.group(2)!);

          final startTime = DateFormat('h:mm A').format(startDateTime);
          final endTime = DateFormat('h:mm A').format(endDateTime);
          return '$startTime ${AppStrings.to.tr()} $endTime';
        }
      } catch (e) {}
    }

    return _formatDefaultTimeRange(date);
  }

  static String _formatDefaultTimeRange(DateTime date) {
    final startTime = DateFormat('h:mm A').format(date);
    final endTime = DateFormat('h:mm A').format(date.add(const Duration(minutes: sessionDurationMinutes)));
    return '$startTime ${AppStrings.to.tr()} $endTime';
  }
}

class TimeSlotParsed {
  final String startTimeIso;
  final String endTimeIso;

  const TimeSlotParsed({required this.startTimeIso, required this.endTimeIso});
}
