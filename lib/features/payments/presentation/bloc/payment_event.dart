import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class AddPaymentMethodRequested extends PaymentEvent {
  final String cardholderName;

  const AddPaymentMethodRequested({required this.cardholderName});

  @override
  List<Object> get props => [cardholderName];
}

class LoadPaymentMethods extends PaymentEvent {
  const LoadPaymentMethods();
}

class DeletePaymentMethodRequested extends PaymentEvent {
  final String paymentMethodId;

  const DeletePaymentMethodRequested({required this.paymentMethodId});

  @override
  List<Object> get props => [paymentMethodId];
}
