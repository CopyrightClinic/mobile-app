import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_payment_method_usecase.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import '../../domain/usecases/delete_payment_method_usecase.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final AddPaymentMethodUseCase addPaymentMethodUseCase;
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final DeletePaymentMethodUseCase deletePaymentMethodUseCase;

  PaymentBloc({required this.addPaymentMethodUseCase, required this.getPaymentMethodsUseCase, required this.deletePaymentMethodUseCase})
    : super(const PaymentInitial()) {
    on<AddPaymentMethodRequested>(_onAddPaymentMethodRequested);
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<DeletePaymentMethodRequested>(_onDeletePaymentMethodRequested);
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

  Future<void> _onLoadPaymentMethods(LoadPaymentMethods event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());

    final result = await getPaymentMethodsUseCase(NoParams());

    result.fold(
      (failure) => emit(PaymentError(failure.message ?? AppStrings.failedToLoadPaymentMethods)),
      (paymentMethods) => emit(PaymentMethodsLoaded(paymentMethods)),
    );
  }

  Future<void> _onDeletePaymentMethodRequested(DeletePaymentMethodRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());

    final result = await deletePaymentMethodUseCase(DeletePaymentMethodParams(paymentMethodId: event.paymentMethodId));

    result.fold(
      (failure) => emit(PaymentError(failure.message ?? AppStrings.failedToDeletePaymentMethod)),
      (message) => emit(PaymentMethodDeleted(message)),
    );
  }
}
