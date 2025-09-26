// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stripePaymentMethodId: json['stripePaymentMethodId'] as String,
      isDefault: json['isDefault'] as bool,
      paymentMethodDetail: PaymentMethodDetailModel.fromJson(
        json['paymentMethodDetail'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'stripePaymentMethodId': instance.stripePaymentMethodId,
      'isDefault': instance.isDefault,
      'paymentMethodDetail': instance.paymentMethodDetail,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PaymentMethodDetailModel _$PaymentMethodDetailModelFromJson(
  Map<String, dynamic> json,
) => PaymentMethodDetailModel(
  id: json['id'] as String,
  type: json['type'] as String,
  card: CardModel.fromJson(json['card'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentMethodDetailModelToJson(
  PaymentMethodDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'card': instance.card,
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
