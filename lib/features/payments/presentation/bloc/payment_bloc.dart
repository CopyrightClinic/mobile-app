import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger/logger.dart';
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
    Log.d('PaymentBloc', 'PaymentBloc initialized');
    on<CreateSetupIntentRequested>(_onCreateSetupIntentRequested);
    on<AddPaymentMethodRequested>(_onAddPaymentMethodRequested);
    on<GetPaymentMethodsRequested>(_onGetPaymentMethodsRequested);
  }

  Future<void> _onCreateSetupIntentRequested(CreateSetupIntentRequested event, Emitter<PaymentState> emit) async {
    Log.d('PaymentBloc', 'CreateSetupIntentRequested event received');
    emit(const PaymentLoading());

    final result = await createSetupIntentUseCase(NoParams());

    result.fold(
      (failure) {
        Log.e('PaymentBloc', 'Failed to create setup intent: ${failure.message}');
        emit(PaymentError(failure.message ?? 'Failed to create setup intent'));
      },
      (setupIntent) {
        Log.d('PaymentBloc', 'Setup intent created successfully: ${setupIntent.id}');
        emit(SetupIntentCreated(setupIntent));
      },
    );
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

      Log.d('PaymentBloc', 'Attaching payment method to customer via backend...');
      final result = await addPaymentMethodUseCase(AddPaymentMethodParams(paymentMethodId: paymentMethod.id));

      result.fold(
        (failure) {
          Log.e('PaymentBloc', 'Failed to attach payment method: ${failure.message}');
          emit(PaymentError(failure.message ?? 'Failed to add payment method'));
        },
        (attachedPaymentMethod) {
          Log.d('PaymentBloc', 'Payment method attached successfully: ${attachedPaymentMethod.id}');
          emit(PaymentMethodAdded(attachedPaymentMethod));
        },
      );
    } catch (e, stackTrace) {
      Log.e('PaymentBloc', 'Exception during payment method creation: $e', stackTrace);
      emit(PaymentError('Failed to process payment method: $e'));
    }
  }

  Future<void> _onGetPaymentMethodsRequested(GetPaymentMethodsRequested event, Emitter<PaymentState> emit) async {
    Log.d('PaymentBloc', 'GetPaymentMethodsRequested event received');
    emit(const PaymentLoading());

    final result = await getPaymentMethodsUseCase(NoParams());

    result.fold(
      (failure) {
        Log.e('PaymentBloc', 'Failed to load payment methods: ${failure.message}');
        emit(PaymentError(failure.message ?? 'Failed to load payment methods'));
      },
      (paymentMethods) {
        Log.d('PaymentBloc', 'Payment methods loaded successfully: ${paymentMethods.length} methods');
        emit(PaymentMethodsLoaded(paymentMethods));
      },
    );
  }
}
