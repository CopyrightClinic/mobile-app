import 'package:equatable/equatable.dart';

import 'consultation_fee.dart';
import 'harold_party_mentioned.dart';

class HaroldEvaluationResult extends Equatable {
  final bool success;
  final String? id;
  final bool isLegitimate;
  final List<String> workTypes;
  final bool? mayInvolveDispute;
  final String? userType;
  final List<HaroldPartyMentioned> partiesMentioned;
  final ConsultationFee? fee;

  const HaroldEvaluationResult({
    required this.success,
    required this.id,
    required this.isLegitimate,
    required this.workTypes,
    required this.mayInvolveDispute,
    required this.userType,
    required this.partiesMentioned,
    this.fee,
  });

  @override
  List<Object?> get props => [success, id, isLegitimate, workTypes, mayInvolveDispute, userType, partiesMentioned, fee];

  @override
  String toString() {
    return 'HaroldEvaluationResult(success: $success, id: $id, isLegitimate: $isLegitimate, workTypes: $workTypes, mayInvolveDispute: $mayInvolveDispute, userType: $userType, partiesMentioned: $partiesMentioned, fee: $fee)';
  }

  HaroldEvaluationResult copyWith({
    bool? success,
    String? id,
    bool? isLegitimate,
    List<String>? workTypes,
    bool? mayInvolveDispute,
    String? userType,
    List<HaroldPartyMentioned>? partiesMentioned,
    ConsultationFee? fee,
  }) {
    return HaroldEvaluationResult(
      success: success ?? this.success,
      id: id ?? this.id,
      isLegitimate: isLegitimate ?? this.isLegitimate,
      workTypes: workTypes ?? this.workTypes,
      mayInvolveDispute: mayInvolveDispute ?? this.mayInvolveDispute,
      userType: userType ?? this.userType,
      partiesMentioned: partiesMentioned ?? this.partiesMentioned,
      fee: fee ?? this.fee,
    );
  }
}
