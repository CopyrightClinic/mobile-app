import '../../../../core/utils/typedefs/type_defs.dart';
import '../../domain/entities/harold_evaluation_result.dart';

class HaroldEvaluateResponseModel {
  final bool success;
  final bool isLegitimate;
  final String reasoning;

  const HaroldEvaluateResponseModel({required this.success, required this.isLegitimate, required this.reasoning});

  factory HaroldEvaluateResponseModel.fromJson(JSON json) {
    return HaroldEvaluateResponseModel(
      success: json['success'] as bool,
      isLegitimate: json['isLegitimate'] as bool,
      reasoning: json['reasoning'] as String,
    );
  }

  JSON toJson() {
    return {'success': success, 'isLegitimate': isLegitimate, 'reasoning': reasoning};
  }

  HaroldEvaluationResult toEntity() {
    return HaroldEvaluationResult(success: success, isLegitimate: isLegitimate, reasoning: reasoning);
  }

  @override
  String toString() {
    return 'HaroldEvaluateResponseModel(success: $success, isLegitimate: $isLegitimate, reasoning: $reasoning)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HaroldEvaluateResponseModel && other.success == success && other.isLegitimate == isLegitimate && other.reasoning == reasoning;
  }

  @override
  int get hashCode => success.hashCode ^ isLegitimate.hashCode ^ reasoning.hashCode;
}
