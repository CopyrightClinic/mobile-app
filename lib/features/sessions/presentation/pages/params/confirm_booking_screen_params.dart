import '../../../../payments/domain/entities/payment_method_entity.dart';
import '../../../domain/entities/session_availability_entity.dart';

class ConfirmBookingScreenParams {
  final DateTime sessionDate;
  final String timeSlot;
  final PaymentMethodEntity paymentMethod;
  final String query;
  final SessionFeeEntity fee;

  const ConfirmBookingScreenParams({
    required this.sessionDate,
    required this.timeSlot,
    required this.paymentMethod,
    required this.query,
    required this.fee,
  });
}
