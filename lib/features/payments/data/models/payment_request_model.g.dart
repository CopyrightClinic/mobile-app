// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentMethodRequestModel _$CreatePaymentMethodRequestModelFromJson(
  Map<String, dynamic> json,
) => CreatePaymentMethodRequestModel(
  stripePaymentMethodId: json['stripePaymentMethodId'] as String,
  isDefault: json['isDefault'] as bool,
);

Map<String, dynamic> _$CreatePaymentMethodRequestModelToJson(
  CreatePaymentMethodRequestModel instance,
) => <String, dynamic>{
  'stripePaymentMethodId': instance.stripePaymentMethodId,
  'isDefault': instance.isDefault,
};
