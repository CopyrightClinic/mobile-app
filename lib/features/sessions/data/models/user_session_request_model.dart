import '../../../../core/utils/enumns/ui/session_request_status.dart';
import '../../domain/entities/user_session_request_entity.dart';

class SessionRequestHoldModel {
  final double sessionFee;
  final double processingFee;
  final double totalAmount;
  final String currency;
  final String status;

  const SessionRequestHoldModel({
    required this.sessionFee,
    required this.processingFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
  });

  factory SessionRequestHoldModel.fromJson(Map<String, dynamic> json) {
    return SessionRequestHoldModel(
      sessionFee: (json['sessionFee'] as num? ?? 0).toDouble(),
      processingFee: (json['processingFee'] as num? ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
    );
  }

  SessionRequestHoldEntity toEntity() => SessionRequestHoldEntity(
    sessionFee: sessionFee,
    processingFee: processingFee,
    totalAmount: totalAmount,
    currency: currency,
    status: status,
  );
}

class UserSessionRequestModel {
  final String id;
  final String requestedDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? summary;
  final bool isFreeSession;
  final String? couponCode;
  final SessionRequestHoldModel? hold;
  final DateTime? expiresAt;
  final DateTime? canceledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSessionRequestModel({
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

  factory UserSessionRequestModel.fromJson(Map<String, dynamic> json) {
    return UserSessionRequestModel(
      id: json['id'] as String,
      requestedDate: json['requestedDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
      summary: json['summary'] as String?,
      isFreeSession: json['isFreeSession'] as bool? ?? false,
      couponCode: json['couponCode'] as String?,
      hold: json['hold'] != null ? SessionRequestHoldModel.fromJson(json['hold'] as Map<String, dynamic>) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.parse(json['canceledAt'] as String) : null,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserSessionRequestEntity toEntity() {
    return UserSessionRequestEntity(
      id: id,
      requestedDate: requestedDate,
      startTime: startTime,
      endTime: endTime,
      status: SessionRequestStatus.fromString(status),
      summary: summary,
      isFreeSession: isFreeSession,
      couponCode: couponCode,
      hold: hold?.toEntity(),
      expiresAt: expiresAt,
      canceledAt: canceledAt,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
