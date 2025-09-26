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

GetPaymentMethodsResponseModel _$GetPaymentMethodsResponseModelFromJson(
  Map<String, dynamic> json,
) => GetPaymentMethodsResponseModel(
  message: json['message'] as String,
  paymentMethods:
      (json['paymentMethods'] as List<dynamic>)
          .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$GetPaymentMethodsResponseModelToJson(
  GetPaymentMethodsResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'paymentMethods': instance.paymentMethods,
};
