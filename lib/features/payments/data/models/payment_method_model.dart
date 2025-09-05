import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_method_entity.dart';

part 'payment_method_model.g.dart';

@JsonSerializable()
class PaymentMethodModel {
  final String id;
  final String userId;
  final String stripePaymentMethodId;
  final bool isDefault;
  final PaymentMethodDetailModel paymentMethodDetail;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.stripePaymentMethodId,
    required this.isDefault,
    required this.paymentMethodDetail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) => _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  PaymentMethodEntity toEntity() => PaymentMethodEntity(
    id: id,
    customerId: userId,
    type: paymentMethodDetail.type,
    card: paymentMethodDetail.card.toEntity(),
    createdAt: createdAt,
  );
}

@JsonSerializable()
class PaymentMethodDetailModel {
  final String id;
  final String type;
  final CardModel card;

  const PaymentMethodDetailModel({required this.id, required this.type, required this.card});

  factory PaymentMethodDetailModel.fromJson(Map<String, dynamic> json) => _$PaymentMethodDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodDetailModelToJson(this);
}

@JsonSerializable()
class CardModel {
  final String brand;
  final String last4;
  @JsonKey(name: 'exp_month')
  final int expMonth;
  @JsonKey(name: 'exp_year')
  final int expYear;

  const CardModel({required this.brand, required this.last4, required this.expMonth, required this.expYear});

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  CardEntity toEntity() => CardEntity(brand: brand, last4: last4, expMonth: expMonth, expYear: expYear);
}
