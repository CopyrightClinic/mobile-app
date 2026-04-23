import '../../../../core/utils/typedefs/type_defs.dart';
import '../../domain/entities/consultation_fee.dart';
import '../../domain/entities/harold_evaluation_result.dart';
import '../../domain/entities/harold_party_mentioned.dart';

class HaroldEvaluateResponseModel {
  final bool success;
  final String? id;
  final bool isLegitimate;
  final List<String> workTypes;
  final bool? mayInvolveDispute;
  final String? userType;
  final List<HaroldPartyMentioned> partiesMentioned;
  final ConsultationFee? fee;

  const HaroldEvaluateResponseModel({
    required this.success,
    required this.id,
    required this.isLegitimate,
    required this.workTypes,
    required this.mayInvolveDispute,
    required this.userType,
    required this.partiesMentioned,
    this.fee,
  });

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

    final rawWorkTypes = json['workTypes'];
    final workTypes = rawWorkTypes is List ? rawWorkTypes.whereType<String>().toList() : <String>[];

    final rawParties = json['partiesMentioned'];
    final partiesMentioned =
        rawParties is List
            ? rawParties
                .whereType<Map>()
                .map((p) {
                  final map = Map<String, dynamic>.from(p);
                  return HaroldPartyMentioned(name: (map['name'] ?? '').toString(), kind: (map['kind'] ?? '').toString());
                })
                .where((p) => p.name.isNotEmpty && p.kind.isNotEmpty)
                .toList()
            : <HaroldPartyMentioned>[];

    return HaroldEvaluateResponseModel(
      success: json['success'] as bool,
      id: json['id']?.toString(),
      isLegitimate: json['isLegitimate'] as bool,
      workTypes: workTypes,
      mayInvolveDispute: json['mayInvolveDispute'] as bool?,
      userType: json['userType']?.toString(),
      partiesMentioned: partiesMentioned,
      fee: fee,
    );
  }

  JSON toJson() {
    final json = {
      'success': success,
      'id': id,
      'isLegitimate': isLegitimate,
      'workTypes': workTypes,
      'mayInvolveDispute': mayInvolveDispute,
      'userType': userType,
      'partiesMentioned': partiesMentioned.map((p) => {'name': p.name, 'kind': p.kind}).toList(),
    };

    if (fee != null) {
      json['fee'] = {'sessionFee': fee!.sessionFee, 'processingFee': fee!.processingFee, 'totalFee': fee!.totalFee, 'currency': fee!.currency};
    }

    return json;
  }

  HaroldEvaluationResult toEntity() {
    return HaroldEvaluationResult(
      success: success,
      id: id,
      isLegitimate: isLegitimate,
      workTypes: workTypes,
      mayInvolveDispute: mayInvolveDispute,
      userType: userType,
      partiesMentioned: partiesMentioned,
      fee: fee,
    );
  }

  @override
  String toString() {
    return 'HaroldEvaluateResponseModel(success: $success, id: $id, isLegitimate: $isLegitimate, workTypes: $workTypes, mayInvolveDispute: $mayInvolveDispute, userType: $userType, partiesMentioned: $partiesMentioned, fee: $fee)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HaroldEvaluateResponseModel &&
        other.success == success &&
        other.id == id &&
        other.isLegitimate == isLegitimate &&
        other.workTypes == workTypes &&
        other.mayInvolveDispute == mayInvolveDispute &&
        other.userType == userType &&
        other.partiesMentioned == partiesMentioned &&
        other.fee == fee;
  }

  @override
  int get hashCode =>
      success.hashCode ^
      id.hashCode ^
      isLegitimate.hashCode ^
      workTypes.hashCode ^
      mayInvolveDispute.hashCode ^
      userType.hashCode ^
      partiesMentioned.hashCode ^
      fee.hashCode;
}
