import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String customerId;
  final String type;
  final CardEntity card;
  final DateTime createdAt;

  const PaymentMethodEntity({required this.id, required this.customerId, required this.type, required this.card, required this.createdAt});

  @override
  List<Object?> get props => [id, customerId, type, card, createdAt];
}

class CardEntity extends Equatable {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  const CardEntity({required this.brand, required this.last4, required this.expMonth, required this.expYear});

  @override
  List<Object?> get props => [brand, last4, expMonth, expYear];
}
