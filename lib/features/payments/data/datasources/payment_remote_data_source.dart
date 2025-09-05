import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/utils/logger/logger.dart';
import '../models/payment_method_model.dart';
import '../models/setup_intent_model.dart';

abstract class PaymentRemoteDataSource {
  Future<SetupIntentModel> createSetupIntent();
  Future<PaymentMethodModel> attachPaymentMethod(String paymentMethodId);
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<bool> deletePaymentMethod(String paymentMethodId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<SetupIntentModel> createSetupIntent() async {
    Log.d('PaymentRemoteDataSource', 'API call: Creating setup intent');
    try {
      final setupIntent = await apiService.postData<SetupIntentModel>(
        endpoint: '/payments/setup-intent',
        data: {},
        converter: (response) => SetupIntentModel.fromJson(response.data['data']),
      );
      Log.d('PaymentRemoteDataSource', 'API response: Setup intent created successfully - ID: ${setupIntent.id}');
      return setupIntent;
    } catch (e, stackTrace) {
      Log.e('PaymentRemoteDataSource', 'API error: Failed to create setup intent - $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<PaymentMethodModel> attachPaymentMethod(String paymentMethodId) async {
    Log.d('PaymentRemoteDataSource', 'API call: Attaching payment method - ID: $paymentMethodId');
    try {
      final paymentMethod = await apiService.postData<PaymentMethodModel>(
        endpoint: '/payments/attach-payment-method',
        data: {'payment_method_id': paymentMethodId},
        converter: (response) => PaymentMethodModel.fromJson(response.data['data']),
      );
      Log.d('PaymentRemoteDataSource', 'API response: Payment method attached successfully - ID: ${paymentMethod.id}');
      return paymentMethod;
    } catch (e, stackTrace) {
      Log.e('PaymentRemoteDataSource', 'API error: Failed to attach payment method $paymentMethodId - $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    Log.d('PaymentRemoteDataSource', 'API call: Fetching payment methods');
    try {
      final paymentMethods = await apiService.getCollectionData<PaymentMethodModel>(
        endpoint: '/payments/methods',
        converter: (responseBody) => PaymentMethodModel.fromJson(responseBody),
      );
      Log.d('PaymentRemoteDataSource', 'API response: Payment methods fetched successfully - Count: ${paymentMethods.length}');
      return paymentMethods;
    } catch (e, stackTrace) {
      Log.e('PaymentRemoteDataSource', 'API error: Failed to fetch payment methods - $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    Log.d('PaymentRemoteDataSource', 'API call: Deleting payment method - ID: $paymentMethodId');
    try {
      final result = await apiService.deleteData<bool>(
        endpoint: '/payments/methods/$paymentMethodId',
        converter: (response) => response.data['success'] == true,
      );
      Log.d('PaymentRemoteDataSource', 'API response: Payment method deleted successfully - ID: $paymentMethodId, Success: $result');
      return result;
    } catch (e, stackTrace) {
      Log.e('PaymentRemoteDataSource', 'API error: Failed to delete payment method $paymentMethodId - $e', stackTrace);
      rethrow;
    }
  }
}
