import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../domain/usecases/add_payment_method_usecase.dart';
import '../../../../core/constants/app_strings.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final AddPaymentMethodUseCase addPaymentMethodUseCase;

  PaymentBloc({required this.addPaymentMethodUseCase}) : super(const PaymentInitial()) {
    on<AddPaymentMethodRequested>(_onAddPaymentMethodRequested);
  }

  Future<void> _onAddPaymentMethodRequested(AddPaymentMethodRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData(billingDetails: BillingDetails(name: event.cardholderName))),
      );

      final result = await addPaymentMethodUseCase(AddPaymentMethodParams(paymentMethodId: paymentMethod.id));

      result.fold(
        (failure) {
          emit(PaymentError(failure.message ?? AppStrings.failedToAddPaymentMethod));
        },
        (createdPaymentMethod) {
          emit(PaymentMethodAdded(createdPaymentMethod));
        },
      );
    } catch (e) {
      emit(PaymentError(AppStrings.failedToProcessPaymentMethod));
    }
  }
}
