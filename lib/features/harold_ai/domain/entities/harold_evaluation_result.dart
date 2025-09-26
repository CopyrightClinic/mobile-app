import 'package:equatable/equatable.dart';

class HaroldEvaluationResult extends Equatable {
  final bool success;
  final bool isLegitimate;
  final String reasoning;

  const HaroldEvaluationResult({required this.success, required this.isLegitimate, required this.reasoning});

  @override
  List<Object?> get props => [success, isLegitimate, reasoning];

  @override
  String toString() {
    return 'HaroldEvaluationResult(success: $success, isLegitimate: $isLegitimate, reasoning: $reasoning)';
  }

  HaroldEvaluationResult copyWith({bool? success, bool? isLegitimate, String? reasoning}) {
    return HaroldEvaluationResult(
      success: success ?? this.success,
      isLegitimate: isLegitimate ?? this.isLegitimate,
      reasoning: reasoning ?? this.reasoning,
    );
  }
}
