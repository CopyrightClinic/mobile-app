import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';

class SessionEntity extends Equatable {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final Duration duration;
  final double price;
  final SessionStatus status;
  final String? description;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? zoomMeetingNumber;
  final String? zoomPasscode;

  const SessionEntity({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.duration,
    required this.price,
    required this.status,
    this.description,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
    this.zoomMeetingNumber,
    this.zoomPasscode,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    scheduledDate,
    duration,
    price,
    status,
    description,
    createdAt,
    cancelledAt,
    cancellationReason,
    zoomMeetingNumber,
    zoomPasscode,
  ];

  bool get isUpcoming => status.isUpcoming;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;
  bool get canCancel => isUpcoming && scheduledDate.difference(DateTime.now()).inHours > 24;
  bool get canJoin => isUpcoming && zoomMeetingNumber != null && zoomMeetingNumber!.isNotEmpty;

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
