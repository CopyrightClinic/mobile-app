// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_session_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookSessionSlotModel _$BookSessionSlotModelFromJson(
  Map<String, dynamic> json,
) => BookSessionSlotModel(
  start: json['start'] as String,
  end: json['end'] as String,
);

Map<String, dynamic> _$BookSessionSlotModelToJson(
  BookSessionSlotModel instance,
) => <String, dynamic>{'start': instance.start, 'end': instance.end};

BookSessionRequestModel _$BookSessionRequestModelFromJson(
  Map<String, dynamic> json,
) => BookSessionRequestModel(
  stripePaymentMethodId: json['stripePaymentMethodId'] as String,
  couponCode: json['couponCode'] as String?,
  date: json['date'] as String,
  slot: BookSessionSlotModel.fromJson(json['slot'] as Map<String, dynamic>),
  summary: json['summary'] as String,
  eligibilityCategory: json['eligibilityCategory'] as String?,
  eligibilitySummary: json['eligibilitySummary'] as String?,
  eligibilityIsLegitimate: json['eligibilityIsLegitimate'] as bool?,
);

Map<String, dynamic> _$BookSessionRequestModelToJson(
  BookSessionRequestModel instance,
) => <String, dynamic>{
  'stripePaymentMethodId': instance.stripePaymentMethodId,
  'couponCode': instance.couponCode,
  'date': instance.date,
  'slot': instance.slot,
  'summary': instance.summary,
  if (instance.eligibilityCategory case final value?)
    'eligibilityCategory': value,
  if (instance.eligibilitySummary case final value?)
    'eligibilitySummary': value,
  if (instance.eligibilityIsLegitimate case final value?)
    'eligibilityIsLegitimate': value,
};
