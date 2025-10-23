import '../../data/models/notification_data_model.dart';
import 'notification_entity.dart';

extension NotificationEntityExtensions on NotificationEntity {
  SessionNotificationData? get sessionData {
    final dataModel = data;
    if (dataModel is SessionNotificationData) {
      return dataModel;
    }
    return null;
  }

  PaymentNotificationData? get paymentData {
    final dataModel = data;
    if (dataModel is PaymentNotificationData) {
      return dataModel;
    }
    return null;
  }

  bool get hasSessionData => sessionData != null;

  bool get hasPaymentData => paymentData != null;
}

