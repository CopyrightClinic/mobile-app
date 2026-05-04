import '../../../../core/utils/typedefs/type_defs.dart';
import '../../domain/entities/harold_eligibility_result.dart';

class HaroldEligibilityResponseModel {
  final String category;
  final String summary;
  final bool isLegitimate;

  const HaroldEligibilityResponseModel({required this.category, required this.summary, required this.isLegitimate});

  factory HaroldEligibilityResponseModel.fromJson(JSON json) {
    return HaroldEligibilityResponseModel(
      category: (json['category'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      isLegitimate: json['isLegitimate'] as bool? ?? false,
    );
  }

  HaroldEligibilityResult toEntity() {
    return HaroldEligibilityResult(category: category, summary: summary, isLegitimate: isLegitimate);
  }
}
