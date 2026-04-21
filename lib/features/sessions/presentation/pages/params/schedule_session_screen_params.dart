class ScheduleSessionScreenParams {
  final String query;
  final String? eligibilityCategory;
  final String? eligibilitySummary;
  final bool? eligibilityIsLegitimate;

  const ScheduleSessionScreenParams({
    required this.query,
    this.eligibilityCategory,
    this.eligibilitySummary,
    this.eligibilityIsLegitimate,
  });
}
