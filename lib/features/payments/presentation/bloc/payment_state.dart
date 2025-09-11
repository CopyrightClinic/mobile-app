import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentMethodAdded extends PaymentState {
  final PaymentMethodEntity paymentMethod;

  const PaymentMethodAdded(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
