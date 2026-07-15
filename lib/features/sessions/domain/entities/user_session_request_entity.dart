import 'package:equatable/equatable.dart';

import '../../../../core/utils/enumns/ui/session_request_status.dart';

class SessionRequestHoldEntity extends Equatable {
  final double amount;
  final String currency;
  final String status;

  const SessionRequestHoldEntity({required this.amount, required this.currency, required this.status});

  @override
  List<Object?> get props => [amount, currency, status];
}

class UserSessionRequestEntity extends Equatable {
  final String id;
  final String requestedDate;
  final String startTime;
  final String endTime;
  final SessionRequestStatus status;
  final String? summary;
  final bool isFreeSession;
  final String? couponCode;
  final SessionRequestHoldEntity? hold;
  final DateTime? expiresAt;
  final DateTime? canceledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSessionRequestEntity({
    required this.id,
    required this.requestedDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.summary,
    required this.isFreeSession,
    this.couponCode,
    this.hold,
    this.expiresAt,
    this.canceledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status.isPending;

  bool get isCanceled => status.isCanceled;

  DateTime get scheduledDateTime {
    try {
      return DateTime.parse('${requestedDate}T$startTime');
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDuration {
    try {
      final start = DateTime.parse('${requestedDate}T$startTime');
      final end = DateTime.parse('${requestedDate}T$endTime');
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
      return '';
    }
  }

  String get formattedHoldAmount => '\$${(hold?.amount ?? 0).toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
    id,
    requestedDate,
    startTime,
    endTime,
    status,
    summary,
    isFreeSession,
    couponCode,
    hold,
    expiresAt,
    canceledAt,
    cancellationReason,
    createdAt,
    updatedAt,
  ];
}
