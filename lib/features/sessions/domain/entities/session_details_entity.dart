import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';

class SessionDetailsAttorneyEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileUrl;

  const SessionDetailsAttorneyEntity({required this.id, required this.name, required this.email, this.profileUrl});

  @override
  List<Object?> get props => [id, name, email, profileUrl];
}

class SessionDetailsUserEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const SessionDetailsUserEntity({required this.id, required this.name, required this.email});

  @override
  List<Object?> get props => [id, name, email];
}

class SessionRequestEntity extends Equatable {
  final String id;
  final String summary;

  const SessionRequestEntity({required this.id, required this.summary});

  @override
  List<Object?> get props => [id, summary];
}

class SessionDetailsEntity extends Equatable {
  final String id;
  final String scheduledDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final SessionStatus status;
  final String? summary;
  final bool summaryLocked;
  final double? rating;
  final String? review;
  final String? cancelTime;
  final bool? cancelTimeExpired;
  final SessionDetailsAttorneyEntity attorney;
  final SessionDetailsUserEntity user;
  final SessionRequestEntity sessionRequest;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? holdAmount;
  final bool canCancel;

  const SessionDetailsEntity({
    required this.id,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.summary,
    required this.summaryLocked,
    this.rating,
    this.review,
    this.cancelTime,
    this.cancelTimeExpired,
    required this.attorney,
    required this.user,
    required this.sessionRequest,
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
    summaryLocked,
    rating,
    review,
    cancelTime,
    cancelTimeExpired,
    attorney,
    user,
    sessionRequest,
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
