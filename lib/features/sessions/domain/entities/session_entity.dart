import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';

class AttorneyEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const AttorneyEntity({required this.id, required this.name, required this.email});

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
    createdAt,
    updatedAt,
    holdAmount,
    canCancel,
  ];

  bool get isUpcoming => status.isUpcoming;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
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
