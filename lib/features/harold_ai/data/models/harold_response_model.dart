import '../../../../core/utils/typedefs/type_defs.dart';
import '../../domain/entities/consultation_fee.dart';
import '../../domain/entities/harold_evaluation_result.dart';

class HaroldEvaluateResponseModel {
  final bool success;
  final bool isLegitimate;
  final String reasoning;
  final ConsultationFee? fee;

  const HaroldEvaluateResponseModel({required this.success, required this.isLegitimate, required this.reasoning, this.fee});

  factory HaroldEvaluateResponseModel.fromJson(JSON json) {
    ConsultationFee? fee;
    if (json['fee'] != null && json['fee'] is Map) {
      final feeJson = json['fee'] as Map<String, dynamic>;
      fee = ConsultationFee(
        sessionFee: (feeJson['sessionFee'] as num).toDouble(),
        processingFee: (feeJson['processingFee'] as num).toDouble(),
        totalFee: (feeJson['totalFee'] as num).toDouble(),
        currency: feeJson['currency'] as String,
      );
    }

    return HaroldEvaluateResponseModel(
      success: json['success'] as bool,
      isLegitimate: json['isLegitimate'] as bool,
      reasoning: json['reasoning'] as String,
      fee: fee,
    );
  }

  JSON toJson() {
    final json = {'success': success, 'isLegitimate': isLegitimate, 'reasoning': reasoning};

    if (fee != null) {
      json['fee'] = {'sessionFee': fee!.sessionFee, 'processingFee': fee!.processingFee, 'totalFee': fee!.totalFee, 'currency': fee!.currency};
    }

    return json;
  }

  HaroldEvaluationResult toEntity() {
    return HaroldEvaluationResult(success: success, isLegitimate: isLegitimate, reasoning: reasoning, fee: fee);
  }

  @override
  String toString() {
    return 'HaroldEvaluateResponseModel(success: $success, isLegitimate: $isLegitimate, reasoning: $reasoning, fee: $fee)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HaroldEvaluateResponseModel &&
        other.success == success &&
        other.isLegitimate == isLegitimate &&
        other.reasoning == reasoning &&
        other.fee == fee;
  }

  @override
  int get hashCode => success.hashCode ^ isLegitimate.hashCode ^ reasoning.hashCode ^ fee.hashCode;
}
