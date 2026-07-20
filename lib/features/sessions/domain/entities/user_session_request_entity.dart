import 'package:equatable/equatable.dart';

class SessionRequestHoldEntity extends Equatable {
  final double sessionFee;
  final double processingFee;
  final double totalAmount;
  final String currency;
  final String status;

  const SessionRequestHoldEntity({
    required this.sessionFee,
    required this.processingFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
  });

  @override
  List<Object?> get props => [sessionFee, processingFee, totalAmount, currency, status];
}

class UserSessionRequestEntity extends Equatable {
  final String id;
  final String requestedDate;
  final String startTime;
  final String endTime;
  final String status;
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

  bool get isPending => status == 'pending';

  bool get isCanceled => status == 'canceled';

  DateTime get scheduledDateTime {
    try {
      return DateTime.parse('${requestedDate}T$startTime');
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime get endDateTime {
    try {
      return DateTime.parse('${requestedDate}T$endTime');
    } catch (e) {
      return scheduledDateTime;
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

  String get formattedHoldAmount => '\$${(hold?.sessionFee ?? 0).toStringAsFixed(2)}';

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
