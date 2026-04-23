import '../../../domain/entities/consultation_fee.dart';

/// Returned with [context.pop] when the user leaves the review to edit answers from the start.
const String kHaroldIntakeReviewPopEditFromStart = 'harold_intake_review_edit_from_start';

class HaroldIntakeReviewRow {
  final String question;
  final String answer;

  const HaroldIntakeReviewRow({required this.question, required this.answer});
}

class HaroldIntakeReviewScreenParams {
  final bool fromAuthFlow;
  final String query;
  final ConsultationFee? fee;
  final String? evaluationId;
  final List<HaroldIntakeReviewRow> rows;
  final Map<String, dynamic> eligibilityPayload;

  const HaroldIntakeReviewScreenParams({
    required this.fromAuthFlow,
    required this.query,
    this.fee,
    this.evaluationId,
    required this.rows,
    required this.eligibilityPayload,
  });
}
