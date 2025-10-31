import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';
import 'session_availability_entity.dart';

class AttorneyEntity extends Equatable {
  final String id;
  final String? name;
  final String email;

  const AttorneyEntity({required this.id, this.name, required this.email});

  @override
  List<Object?> get props => [id, name, email];
}

class SessionEntity extends Equatable {
  final String id;
  final String scheduledDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final SessionStatus status;
  final String? summary;
  final double? rating;
  final String? review;
  final String? cancelTime;
  final bool? cancelTimeExpired;
  final AttorneyEntity attorney;
  final SessionFeeEntity? sessionFee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? holdAmount;
  final bool canCancel;

  const SessionEntity({
    required this.id,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.summary,
    this.rating,
    this.review,
    this.cancelTime,
    this.cancelTimeExpired,
    required this.attorney,
    this.sessionFee,
    required this.createdAt,
    required this.updatedAt,
    this.holdAmount,
    required this.canCancel,
  });

  @override
  List<Object?> get props => [
    id,
    scheduledDate,
    startTime,
    endTime,
    durationMinutes,
    status,
    summary,
    rating,
    review,
    cancelTime,
    cancelTimeExpired,
    attorney,
    sessionFee,
    createdAt,
    updatedAt,
    holdAmount,
    canCancel,
  ];

  bool get isUpcoming => status.isUpcoming;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;

  bool get canJoin {
    if (!isUpcoming) return false;

    final now = DateTime.now();
    final sessionStart = scheduledDateTime;
    final tenMinutesBeforeSession = sessionStart.subtract(const Duration(minutes: 10));

    return now.isAfter(tenMinutesBeforeSession) || now.isAtSameMomentAs(tenMinutesBeforeSession);
  }

  bool get canRequestSummary {
    if (!isCompleted) return false;

    final now = DateTime.now();
    final sessionEnd = scheduledDateTime.add(Duration(minutes: durationMinutes));
    final oneHourAfterSession = sessionEnd.add(const Duration(hours: 1));
    final fifteenDaysAfterSession = sessionEnd.add(const Duration(days: 15));

    return (now.isAfter(oneHourAfterSession) || now.isAtSameMomentAs(oneHourAfterSession)) && now.isBefore(fifteenDaysAfterSession);
  }

  DateTime get summaryRequestDeadline {
    final sessionEnd = scheduledDateTime.add(Duration(minutes: durationMinutes));
    return sessionEnd.add(const Duration(days: 15));
  }

  bool get hasSummaryRequestExpired {
    if (!isCompleted) return false;
    final now = DateTime.now();
    return now.isAfter(summaryRequestDeadline) || now.isAtSameMomentAs(summaryRequestDeadline);
  }

  String get formattedDuration {
    try {
      final start = DateTime.parse('${scheduledDate}T$startTime');
      final end = DateTime.parse('${scheduledDate}T$endTime');
      final durationInMinutes = end.difference(start).inMinutes;
      
      final hours = durationInMinutes ~/ 60;
      final minutes = durationInMinutes % 60;

      if (hours > 0 && minutes > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      } else if (hours > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      }
    } catch (e) {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      if (hours > 0 && minutes > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      } else if (hours > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      }
    }
  }

  String get formattedHoldAmount => holdAmount != null ? '\$${holdAmount!.toStringAsFixed(2)}' : '';

  DateTime get scheduledDateTime {
    try {
      final dateTime = DateTime.parse('${scheduledDate}T$startTime');
      return dateTime;
    } catch (e) {
      return DateTime.now();
    }
  }
}
