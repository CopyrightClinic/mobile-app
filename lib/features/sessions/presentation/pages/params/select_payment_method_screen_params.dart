import '../../../domain/entities/session_availability_entity.dart';

class SelectPaymentMethodScreenParams {
  final DateTime sessionDate;
  final String timeSlot;
  final String query;
  final SessionFeeEntity fee;
  final String? eligibilitySummary;

  const SelectPaymentMethodScreenParams({
    required this.query,
    required this.sessionDate,
    required this.timeSlot,
    required this.fee,
    this.eligibilitySummary,
  });
}
