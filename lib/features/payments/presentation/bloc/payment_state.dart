import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/setup_intent_entity.dart';

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

class SetupIntentCreated extends PaymentState {
  final SetupIntentEntity setupIntent;

  const SetupIntentCreated(this.setupIntent);

  @override
  List<Object> get props => [setupIntent];
}

class PaymentMethodAdded extends PaymentState {
  final PaymentMethodEntity paymentMethod;

  const PaymentMethodAdded(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object> get props => [paymentMethods];
}

class PaymentMethodDeleted extends PaymentState {
  const PaymentMethodDeleted();
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
