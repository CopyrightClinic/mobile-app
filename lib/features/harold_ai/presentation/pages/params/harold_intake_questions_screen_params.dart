import '../../../domain/entities/consultation_fee.dart';

class HaroldIntakeQuestionsScreenParams {
  final bool fromAuthFlow;
  final String query;
  final ConsultationFee? fee;
  final String? userType;
  final String? evaluationId;

  const HaroldIntakeQuestionsScreenParams({
    this.fromAuthFlow = false,
    required this.query,
    this.fee,
    this.userType,
    this.evaluationId,
  });
}

