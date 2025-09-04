import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_payment_method_usecase.dart';
import '../../domain/usecases/create_setup_intent_usecase.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateSetupIntentUseCase createSetupIntentUseCase;
  final AddPaymentMethodUseCase addPaymentMethodUseCase;
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;

  PaymentBloc({required this.createSetupIntentUseCase, required this.addPaymentMethodUseCase, required this.getPaymentMethodsUseCase})
    : super(const PaymentInitial()) {
    on<CreateSetupIntentRequested>(_onCreateSetupIntentRequested);
    on<AddPaymentMethodRequested>(_onAddPaymentMethodRequested);
    on<GetPaymentMethodsRequested>(_onGetPaymentMethodsRequested);
  }

  Future<void> _onCreateSetupIntentRequested(CreateSetupIntentRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());

    final result = await createSetupIntentUseCase(NoParams());

    result.fold(
      (failure) => emit(PaymentError(failure.message ?? 'Failed to create setup intent')),
      (setupIntent) => emit(SetupIntentCreated(setupIntent)),
    );
  }

  Future<void> _onAddPaymentMethodRequested(AddPaymentMethodRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());

    try {
      // Create payment method with Stripe
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(paymentMethodData: PaymentMethodData(billingDetails: BillingDetails(name: event.cardholderName))),
      );

      // Attach payment method to customer via backend
      final result = await addPaymentMethodUseCase(AddPaymentMethodParams(paymentMethodId: paymentMethod.id));

      result.fold(
        (failure) => emit(PaymentError(failure.message ?? 'Failed to add payment method')),
        (attachedPaymentMethod) => emit(PaymentMethodAdded(attachedPaymentMethod)),
      );
    } catch (e) {
      emit(PaymentError('Failed to process payment method: $e'));
    }
  }

  Future<void> _onGetPaymentMethodsRequested(GetPaymentMethodsRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());

    final result = await getPaymentMethodsUseCase(NoParams());

    result.fold(
      (failure) => emit(PaymentError(failure.message ?? 'Failed to load payment methods')),
      (paymentMethods) => emit(PaymentMethodsLoaded(paymentMethods)),
    );
  }
}
