import 'package:equatable/equatable.dart';

import 'consultation_fee.dart';

class HaroldEvaluationResult extends Equatable {
  final bool success;
  final bool isLegitimate;
  final String reasoning;
  final ConsultationFee? fee;

  const HaroldEvaluationResult({required this.success, required this.isLegitimate, required this.reasoning, this.fee});

  @override
  List<Object?> get props => [success, isLegitimate, reasoning, fee];

  @override
  String toString() {
    return 'HaroldEvaluationResult(success: $success, isLegitimate: $isLegitimate, reasoning: $reasoning, fee: $fee)';
  }

  HaroldEvaluationResult copyWith({bool? success, bool? isLegitimate, String? reasoning, ConsultationFee? fee}) {
    return HaroldEvaluationResult(
      success: success ?? this.success,
      isLegitimate: isLegitimate ?? this.isLegitimate,
      reasoning: reasoning ?? this.reasoning,
      fee: fee ?? this.fee,
    );
  }
}
