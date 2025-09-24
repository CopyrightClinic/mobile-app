import '../../../../payments/domain/entities/payment_method_entity.dart';

class ConfirmBookingScreenParams {
  final DateTime sessionDate;
  final String timeSlot;
  final PaymentMethodEntity paymentMethod;

  const ConfirmBookingScreenParams({required this.sessionDate, required this.timeSlot, required this.paymentMethod});
}
