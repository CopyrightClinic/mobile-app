// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentMethodResponseModel _$CreatePaymentMethodResponseModelFromJson(
  Map<String, dynamic> json,
) => CreatePaymentMethodResponseModel(
  message: json['message'] as String,
  paymentMethod: PaymentMethodModel.fromJson(
    json['paymentMethod'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CreatePaymentMethodResponseModelToJson(
  CreatePaymentMethodResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'paymentMethod': instance.paymentMethod,
};
