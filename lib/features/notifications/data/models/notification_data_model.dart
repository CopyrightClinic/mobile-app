import '../../../../core/utils/enumns/api/notifications_enums.dart';

abstract class NotificationDataModel {
  const NotificationDataModel();

  Map<String, dynamic> toJson();

  factory NotificationDataModel.fromJson(Map<String, dynamic>? json, NotificationType type) {
    if (json == null) return const EmptyNotificationData();

    switch (type) {
      case NotificationType.sessionAccepted:
      case NotificationType.sessionCancelled:
      case NotificationType.sessionReminder:
      case NotificationType.sessionCompleted:
        return SessionNotificationData.fromJson(json);
      case NotificationType.paymentReleased:
      case NotificationType.paymentReceived:
      case NotificationType.paymentAuthorizationFailed:
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
  final String? attorneyName;
  final String? sessionTime;
  final String? reason;

  const SessionNotificationData({this.sessionId, this.attorneyName, this.sessionTime, this.reason});

  factory SessionNotificationData.fromJson(Map<String, dynamic> json) {
    return SessionNotificationData(
      sessionId: json['sessionId'] as String?,
      attorneyName: json['attorneyName'] as String?,
      sessionTime: json['sessionTime'] as String?,
      reason: json['reason'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'sessionId': sessionId,
      if (attorneyName != null) 'attorneyName': attorneyName,
      if (sessionTime != null) 'sessionTime': sessionTime,
      if (reason != null) 'reason': reason,
    };
  }
}

class PaymentNotificationData extends NotificationDataModel {
  final String? paymentId;
  final String? amount;
  final String? currency;
  final String? reason;

  const PaymentNotificationData({this.paymentId, this.amount, this.currency, this.reason});

  factory PaymentNotificationData.fromJson(Map<String, dynamic> json) {
    return PaymentNotificationData(
      paymentId: json['paymentId'] as String?,
      amount: json['amount'] as String?,
      currency: json['currency'] as String?,
      reason: json['reason'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (paymentId != null) 'paymentId': paymentId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (reason != null) 'reason': reason,
    };
  }
}
