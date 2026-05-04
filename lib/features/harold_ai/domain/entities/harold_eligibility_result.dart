import 'package:equatable/equatable.dart';

class HaroldEligibilityResult extends Equatable {
  final String category;
  final String summary;
  final bool isLegitimate;

  const HaroldEligibilityResult({required this.category, required this.summary, required this.isLegitimate});

  @override
  List<Object?> get props => [category, summary, isLegitimate];
}
