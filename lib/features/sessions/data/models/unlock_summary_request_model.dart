import 'package:json_annotation/json_annotation.dart';

part 'unlock_summary_request_model.g.dart';

@JsonSerializable()
class UnlockSummaryRequestModel {
  final String sessionId;
  final String paymentMethodId;
  final double summaryFee;

  const UnlockSummaryRequestModel({required this.sessionId, required this.paymentMethodId, required this.summaryFee});

  factory UnlockSummaryRequestModel.fromJson(Map<String, dynamic> json) => _$UnlockSummaryRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnlockSummaryRequestModelToJson(this);
}
