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
