import '../../../../payments/domain/entities/payment_method_entity.dart';

class ConfirmBookingScreenParams {
  final DateTime sessionDate;
  final String timeSlot;
  final PaymentMethodEntity paymentMethod;
  final String query;

  const ConfirmBookingScreenParams({required this.sessionDate, required this.timeSlot, required this.paymentMethod, required this.query});
}
