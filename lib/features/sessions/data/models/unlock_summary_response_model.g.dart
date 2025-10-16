// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_summary_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockSummaryResponseModel _$UnlockSummaryResponseModelFromJson(
  Map<String, dynamic> json,
) => UnlockSummaryResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  paymentId: json['paymentId'] as String,
);

Map<String, dynamic> _$UnlockSummaryResponseModelToJson(
  UnlockSummaryResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'paymentId': instance.paymentId,
};
