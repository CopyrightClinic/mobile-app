// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      type: json['type'] as String,
      card: CardModel.fromJson(json['card'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'type': instance.type,
      'card': instance.card,
      'created_at': instance.createdAt.toIso8601String(),
    };

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
  brand: json['brand'] as String,
  last4: json['last4'] as String,
  expMonth: (json['exp_month'] as num).toInt(),
  expYear: (json['exp_year'] as num).toInt(),
);

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'brand': instance.brand,
  'last4': instance.last4,
  'exp_month': instance.expMonth,
  'exp_year': instance.expYear,
};
