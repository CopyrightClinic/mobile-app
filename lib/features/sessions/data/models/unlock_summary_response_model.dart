import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/unlock_summary_response_entity.dart';

part 'unlock_summary_response_model.g.dart';

@JsonSerializable()
class UnlockSummaryResponseModel {
  final bool success;
  final String message;
  final String paymentId;

  const UnlockSummaryResponseModel({required this.success, required this.message, required this.paymentId});

  factory UnlockSummaryResponseModel.fromJson(Map<String, dynamic> json) => _$UnlockSummaryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnlockSummaryResponseModelToJson(this);

  UnlockSummaryResponseEntity toEntity() {
    return UnlockSummaryResponseEntity(success: success, message: message, paymentId: paymentId);
  }
}
