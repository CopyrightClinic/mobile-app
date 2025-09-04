import '../../../../core/network/api_service/api_service.dart';
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
    final setupIntent = await apiService.postData<SetupIntentModel>(
      endpoint: '/payments/setup-intent',
      data: {},
      converter: (response) => SetupIntentModel.fromJson(response.data['data']),
    );
    return setupIntent;
  }

  @override
  Future<PaymentMethodModel> attachPaymentMethod(String paymentMethodId) async {
    final paymentMethod = await apiService.postData<PaymentMethodModel>(
      endpoint: '/payments/attach-payment-method',
      data: {'payment_method_id': paymentMethodId},
      converter: (response) => PaymentMethodModel.fromJson(response.data['data']),
    );
    return paymentMethod;
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final paymentMethods = await apiService.getCollectionData<PaymentMethodModel>(
      endpoint: '/payments/methods',
      converter: (responseBody) => PaymentMethodModel.fromJson(responseBody),
    );
    return paymentMethods;
  }

  @override
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    final result = await apiService.deleteData<bool>(
      endpoint: '/payments/methods/$paymentMethodId',
      converter: (response) => response.data['success'] == true,
    );
    return result;
  }
}
