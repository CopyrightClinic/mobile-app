import '../../../domain/entities/consultation_fee.dart';
import '../../../domain/entities/harold_eligibility_result.dart';

class HaroldSuccessScreenParams {
  final bool fromAuthFlow;
  final String? query;
  final ConsultationFee? fee;
  final HaroldEligibilityResult? eligibility;

  const HaroldSuccessScreenParams({this.fromAuthFlow = false, this.query, this.fee, this.eligibility});
}
