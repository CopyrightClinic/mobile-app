import 'package:equatable/equatable.dart';

final class InitiateCheckoutPayload extends Equatable {
  final String checkoutId;
  final String currencyCode;
  final double value;
  final int itemCount;
  final String? primaryItemId;
  final String? primaryItemName;

  const InitiateCheckoutPayload({
    required this.checkoutId,
    required this.currencyCode,
    required this.value,
    required this.itemCount,
    this.primaryItemId,
    this.primaryItemName,
  });

  @override
  List<Object?> get props => [
    checkoutId,
    currencyCode,
    value,
    itemCount,
    primaryItemId,
    primaryItemName,
  ];
}

final class PurchasePayload extends Equatable {
  final String transactionId;
  final String currencyCode;
  final double value;
  final int quantity;
  final String? itemId;
  final String? itemName;
  final String? affiliation;

  const PurchasePayload({
    required this.transactionId,
    required this.currencyCode,
    required this.value,
    this.quantity = 1,
    this.itemId,
    this.itemName,
    this.affiliation,
  });

  @override
  List<Object?> get props => [
    transactionId,
    currencyCode,
    value,
    quantity,
    itemId,
    itemName,
    affiliation,
  ];
}
