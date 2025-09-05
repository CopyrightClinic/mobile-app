import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../domain/usecases/add_payment_method_usecase.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final AddPaymentMethodUseCase addPaymentMethodUseCase;

  PaymentBloc({required this.addPaymentMethodUseCase}) : super(const PaymentInitial()) {
    Log.d('PaymentBloc', 'PaymentBloc initialized');
    on<AddPaymentMethodRequested>(_onAddPaymentMethodRequested);
  }

  Future<void> _onAddPaymentMethodRequested(AddPaymentMethodRequested event, Emitter<PaymentState> emit) async {
    Log.d('PaymentBloc', 'AddPaymentMethodRequested event received for cardholder: ${event.cardholderName}');
    emit(const PaymentLoading());

    try {
      Log.d('PaymentBloc', 'Creating payment method with Stripe using CardFormField...');
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData(billingDetails: BillingDetails(name: event.cardholderName))),
      );
      Log.d('PaymentBloc', 'Stripe payment method created successfully: ${paymentMethod.id}');

      Log.d('PaymentBloc', 'Creating payment method in backend...');
      final result = await addPaymentMethodUseCase(AddPaymentMethodParams(paymentMethodId: paymentMethod.id));

      result.fold(
        (failure) {
          Log.e('PaymentBloc', 'Failed to create payment method: ${failure.message}');
          emit(PaymentError(failure.message ?? 'Failed to add payment method'));
        },
        (createdPaymentMethod) {
          Log.d('PaymentBloc', 'Payment method created successfully: ${createdPaymentMethod.id}');
          emit(PaymentMethodAdded(createdPaymentMethod));
        },
      );
    } catch (e, stackTrace) {
      Log.e('PaymentBloc', 'Exception during payment method creation: $e', stackTrace);
      emit(PaymentError('Failed to process payment method: $e'));
    }
  }
}
