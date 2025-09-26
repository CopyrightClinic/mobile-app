import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/enumns/api/export.dart';
import '../../../../core/utils/typedefs/type_defs.dart';

import '../models/harold_request_model.dart';
import '../models/harold_response_model.dart';

abstract class HaroldRemoteDataSource {
  Future<HaroldEvaluateResponseModel> evaluateQuery(HaroldEvaluateRequestModel request);
}

class HaroldRemoteDataSourceImpl implements HaroldRemoteDataSource {
  final ApiService apiService;

  HaroldRemoteDataSourceImpl({required this.apiService});

  @override
  Future<HaroldEvaluateResponseModel> evaluateQuery(HaroldEvaluateRequestModel request) async {
    try {
      final response = await apiService.postData<HaroldEvaluateResponseModel>(
        endpoint: ApiEndpoint.harold(HaroldEndpoint.EVALUATE),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          try {
            return HaroldEvaluateResponseModel.fromJson(response.data);
          } catch (e) {
            throw CustomException.fromParsingException(e as Exception);
          }
        },
      );
      return response;
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException.fromDioException(e as Exception);
    }
  }
}
