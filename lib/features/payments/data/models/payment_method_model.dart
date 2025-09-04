import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_method_entity.dart';

part 'payment_method_model.g.dart';

@JsonSerializable()
class PaymentMethodModel {
  final String id;
  @JsonKey(name: 'customer_id')
  final String customerId;
  final String type;
  final CardModel card;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const PaymentMethodModel({required this.id, required this.customerId, required this.type, required this.card, required this.createdAt});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) => _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  PaymentMethodEntity toEntity() => PaymentMethodEntity(id: id, customerId: customerId, type: type, card: card.toEntity(), createdAt: createdAt);
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
