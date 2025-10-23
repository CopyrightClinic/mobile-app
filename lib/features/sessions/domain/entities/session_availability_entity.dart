class SessionAvailabilityEntity {
  final DateTime startDate;
  final DateTime endDate;
  final int slotMinutes;
  final List<AvailabilityDayEntity> days;
  final SessionFeeEntity fee;

  const SessionAvailabilityEntity({required this.startDate, required this.endDate, required this.slotMinutes, required this.days, required this.fee});
}

class AvailabilityDayEntity {
  final DateTime date;
  final String weekday;
  final List<TimeSlotEntity> slots;

  const AvailabilityDayEntity({required this.date, required this.weekday, required this.slots});
}

class TimeSlotEntity {
  final DateTime start;
  final DateTime end;

  const TimeSlotEntity({required this.start, required this.end});

  String get formattedTime {
    final startHour = start.hour;
    final startMinute = start.minute;
    final endHour = end.hour;
    final endMinute = end.minute;

    String formatTime(int hour, int minute) {
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');
      return '$displayHour:$displayMinute $period';
    }

    return '${formatTime(startHour, startMinute)} - ${formatTime(endHour, endMinute)}';
  }
}

class SessionFeeEntity {
  final num amount;
  final String currency;

  const SessionFeeEntity({required this.amount, required this.currency});
}
