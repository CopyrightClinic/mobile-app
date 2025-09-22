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

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object> get props => [paymentMethods];
}

class PaymentMethodDeleted extends PaymentState {
  final String message;

  const PaymentMethodDeleted(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentProcessed extends PaymentState {
  final String transactionId;
  final String message;

  const PaymentProcessed({required this.transactionId, required this.message});

  @override
  List<Object> get props => [transactionId, message];
}
