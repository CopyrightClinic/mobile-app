import '../../../../core/utils/enumns/api/notifications_enums.dart';

abstract class NotificationDataModel {
  const NotificationDataModel();

  Map<String, dynamic> toJson();

  factory NotificationDataModel.fromJson(Map<String, dynamic>? json, NotificationType type) {
    if (json == null) return const EmptyNotificationData();

    switch (type) {
      case NotificationType.sessionAccepted:
      case NotificationType.sessionReminder:
      case NotificationType.sessionCompleted:
      case NotificationType.sessionSummaryAvailable:
      case NotificationType.sessionExtensionApproved:
      case NotificationType.sessionExtensionDeclined:
      case NotificationType.sessionExtensionPrompt:
        return SessionNotificationData.fromJson(json);
      case NotificationType.refundIssued:
        return PaymentNotificationData.fromJson(json);
    }
  }
}

class EmptyNotificationData extends NotificationDataModel {
  const EmptyNotificationData();

  @override
  Map<String, dynamic> toJson() => {};
}

class SessionNotificationData extends NotificationDataModel {
  final String? sessionId;
  final String? attorneyId;
  final String? attorneyName;
  final String? userId;
  final String? userName;
  final String? scheduledDate;
  final String? startTime;
  final String? durationMinutes;
  final String? minutesUntilStart;
  final String? zoomLink;
  final String? zoomMeetingId;
  final String? zoomPassword;
  final String? cancelledAt;
  final String? completedAt;
  final String? reason;
  final String? sessionRequestId;
  final String? totalFee;
  final String? extensionFee;

  const SessionNotificationData({
    this.sessionId,
    this.attorneyId,
    this.attorneyName,
    this.userId,
    this.userName,
    this.scheduledDate,
    this.startTime,
    this.durationMinutes,
    this.minutesUntilStart,
    this.zoomLink,
    this.zoomMeetingId,
    this.zoomPassword,
    this.cancelledAt,
    this.completedAt,
    this.reason,
    this.sessionRequestId,
    this.totalFee,
    this.extensionFee,
  });

  factory SessionNotificationData.fromJson(Map<String, dynamic> json) {
    String? totalFee;
    String? extensionFee;

    if (json['fees'] != null && json['fees'] is Map) {
      final fees = json['fees'] as Map<String, dynamic>;
      totalFee = fees['totalFee']?.toString();
      extensionFee = fees['sessionFee']?.toString();
    }

    return SessionNotificationData(
      sessionId: json['sessionId'] as String?,
      attorneyId: json['attorneyId'] as String?,
      attorneyName: json['attorneyName'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      scheduledDate: json['scheduledDate'] as String?,
      startTime: json['startTime'] as String?,
      durationMinutes: json['durationMinutes']?.toString(),
      minutesUntilStart: json['minutesUntilStart']?.toString(),
      zoomLink: json['zoomLink'] as String?,
      zoomMeetingId: json['zoomMeetingId']?.toString(),
      zoomPassword: json['zoomPassword'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      completedAt: json['completedAt'] as String?,
      reason: json['reason'] as String?,
      sessionRequestId: json['sessionRequestId'] as String?,
      totalFee: totalFee ?? json['totalFee']?.toString(),
      extensionFee: extensionFee ?? json['extensionFee']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'sessionId': sessionId,
      if (attorneyId != null) 'attorneyId': attorneyId,
      if (attorneyName != null) 'attorneyName': attorneyName,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (scheduledDate != null) 'scheduledDate': scheduledDate,
      if (startTime != null) 'startTime': startTime,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (minutesUntilStart != null) 'minutesUntilStart': minutesUntilStart,
      if (zoomLink != null) 'zoomLink': zoomLink,
      if (zoomMeetingId != null) 'zoomMeetingId': zoomMeetingId,
      if (zoomPassword != null) 'zoomPassword': zoomPassword,
      if (cancelledAt != null) 'cancelledAt': cancelledAt,
      if (completedAt != null) 'completedAt': completedAt,
      if (reason != null) 'reason': reason,
      if (sessionRequestId != null) 'sessionRequestId': sessionRequestId,
      if (totalFee != null) 'totalFee': totalFee,
      if (extensionFee != null) 'extensionFee': extensionFee,
    };
  }
}

class PaymentNotificationData extends NotificationDataModel {
  final String? sessionId;
  final String? paymentId;
  final String? paymentIntentId;
  final String? refundId;
  final String? amount;
  final String? refundAmount;
  final String? currency;
  final String? paymentMethodLast4;
  final String? failureReason;
  final String? refundReason;
  final String? userId;
  final String? userName;
  final String? releasedAt;

  const PaymentNotificationData({
    this.sessionId,
    this.paymentId,
    this.paymentIntentId,
    this.refundId,
    this.amount,
    this.refundAmount,
    this.currency,
    this.paymentMethodLast4,
    this.failureReason,
    this.refundReason,
    this.userId,
    this.userName,
    this.releasedAt,
  });

  factory PaymentNotificationData.fromJson(Map<String, dynamic> json) {
    return PaymentNotificationData(
      sessionId: json['sessionId'] as String?,
      paymentId: json['paymentId'] as String?,
      paymentIntentId: json['paymentIntentId'] as String?,
      refundId: json['refundId'] as String?,
      amount: json['amount']?.toString(),
      refundAmount: json['refundAmount']?.toString(),
      currency: json['currency'] as String?,
      paymentMethodLast4: json['paymentMethodLast4'] as String?,
      failureReason: json['failureReason'] as String?,
      refundReason: json['refundReason'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      releasedAt: json['releasedAt'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'sessionId': sessionId,
      if (paymentId != null) 'paymentId': paymentId,
      if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
      if (refundId != null) 'refundId': refundId,
      if (amount != null) 'amount': amount,
      if (refundAmount != null) 'refundAmount': refundAmount,
      if (currency != null) 'currency': currency,
      if (paymentMethodLast4 != null) 'paymentMethodLast4': paymentMethodLast4,
      if (failureReason != null) 'failureReason': failureReason,
      if (refundReason != null) 'refundReason': refundReason,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (releasedAt != null) 'releasedAt': releasedAt,
    };
  }
}
