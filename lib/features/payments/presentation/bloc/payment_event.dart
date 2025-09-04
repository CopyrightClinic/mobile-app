import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class CreateSetupIntentRequested extends PaymentEvent {
  const CreateSetupIntentRequested();
}

class AddPaymentMethodRequested extends PaymentEvent {
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardholderName;

  const AddPaymentMethodRequested({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardholderName,
  });

  @override
  List<Object> get props => [cardNumber, expiryMonth, expiryYear, cvv, cardholderName];
}

class GetPaymentMethodsRequested extends PaymentEvent {
  const GetPaymentMethodsRequested();
}

class DeletePaymentMethodRequested extends PaymentEvent {
  final String paymentMethodId;

  const DeletePaymentMethodRequested({required this.paymentMethodId});

  @override
  List<Object> get props => [paymentMethodId];
}
