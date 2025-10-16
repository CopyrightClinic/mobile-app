// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_summary_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockSummaryRequestModel _$UnlockSummaryRequestModelFromJson(
  Map<String, dynamic> json,
) => UnlockSummaryRequestModel(
  sessionId: json['sessionId'] as String,
  paymentMethodId: json['paymentMethodId'] as String,
  summaryFee: (json['summaryFee'] as num).toDouble(),
);

Map<String, dynamic> _$UnlockSummaryRequestModelToJson(
  UnlockSummaryRequestModel instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'paymentMethodId': instance.paymentMethodId,
  'summaryFee': instance.summaryFee,
};
