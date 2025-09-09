import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/enumns/api/export.dart';
import '../../../../core/utils/typedefs/type_defs.dart';

import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';

abstract class PaymentRemoteDataSource {
  Future<CreatePaymentMethodResponseModel> createPaymentMethod(CreatePaymentMethodRequestModel request);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<CreatePaymentMethodResponseModel> createPaymentMethod(CreatePaymentMethodRequestModel request) async {
    try {
      final response = await apiService.postData<CreatePaymentMethodResponseModel>(
        endpoint: ApiEndpoint.payment(PaymentEndpoint.PAYMENT_METHODS),
        data: request.toJson(),
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          try {
            final createPaymentMethodResponse = CreatePaymentMethodResponseModel.fromJson(response.data);
            return createPaymentMethodResponse;
          } catch (e) {
            throw CustomException.fromParsingException(e as Exception);
          }
        },
      );
      return response;
    } catch (e) {
      throw CustomException.fromDioException(e as Exception);
    }
  }
}
