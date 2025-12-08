import '../../../domain/entities/consultation_fee.dart';

class HaroldSuccessScreenParams {
  final bool fromAuthFlow;
  final String? query;
  final ConsultationFee? fee;

  const HaroldSuccessScreenParams({this.fromAuthFlow = false, this.query, this.fee});
}
