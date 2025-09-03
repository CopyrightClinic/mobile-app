import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/enumns/api/export.dart';
import '../../../../core/utils/typedefs/type_defs.dart';

import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<SignupResponseModel> signup(SignupRequestModel request);
  Future<VerifyOtpResponseModel> verifyEmail(VerifyOtpRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await apiService.postData<AuthResponseModel>(
      endpoint: ApiEndpoint.auth(AuthEndpoint.LOGIN),
      data: request.toJson(),
      requiresAuthToken: false,
      converter: (ResponseModel<JSON> response) {
        return AuthResponseModel.fromJson(response.data);
      },
    );
    return response;
  }

  @override
  Future<SignupResponseModel> signup(SignupRequestModel request) async {
    final response = await apiService.postData<SignupResponseModel>(
      endpoint: ApiEndpoint.auth(AuthEndpoint.SIGNUP),
      data: request.toJson(),
      requiresAuthToken: false,
      converter: (ResponseModel<JSON> response) {
        return SignupResponseModel.fromJson(response.data);
      },
    );
    return response;
  }

  @override
  Future<VerifyOtpResponseModel> verifyEmail(VerifyOtpRequestModel request) async {
    final response = await apiService.postData<VerifyOtpResponseModel>(
      endpoint: ApiEndpoint.auth(AuthEndpoint.VERIFY_EMAIL),
      data: request.toJson(),
      requiresAuthToken: false,
      converter: (ResponseModel<JSON> response) {
        return VerifyOtpResponseModel.fromJson(response.data);
      },
    );
    return response;
  }
}
