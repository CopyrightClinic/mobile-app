import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/typedefs/type_defs.dart';
import '../../../../core/utils/logger/logger.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<SignupResponseModel> signup(SignupRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      Log.d('AuthRemoteDataSourceImpl', 'Making login API call to: ${ApiEndpoint.auth(AuthEndpoint.LOGIN)}');
      Log.d('AuthRemoteDataSourceImpl', 'Request data: ${request.toJson()}');

      final response = await apiService.postData<AuthResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.LOGIN),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          Log.d('AuthRemoteDataSourceImpl', 'Raw API response: ${response.data}');
          try {
            final authResponse = AuthResponseModel.fromJson(response.data);
            Log.d('AuthRemoteDataSourceImpl', 'Parsed auth response: ${authResponse.message}');
            return authResponse;
          } catch (e, stackTrace) {
            Log.e('AuthRemoteDataSourceImpl', 'Error parsing auth response: $e', stackTrace);
            rethrow;
          }
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in login API call: $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<SignupResponseModel> signup(SignupRequestModel request) async {
    try {
      Log.d('AuthRemoteDataSourceImpl', 'Making signup API call to: ${ApiEndpoint.auth(AuthEndpoint.SIGNUP)}');
      Log.d('AuthRemoteDataSourceImpl', 'Request data: ${request.toJson()}');

      final response = await apiService.postData<SignupResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.SIGNUP),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          Log.d('AuthRemoteDataSourceImpl', 'Raw API response: ${response.data}');
          try {
            final signupResponse = SignupResponseModel.fromJson(response.data);
            Log.d('AuthRemoteDataSourceImpl', 'Parsed signup response: ${signupResponse.message}');
            return signupResponse;
          } catch (e, stackTrace) {
            Log.e('AuthRemoteDataSourceImpl', 'Error parsing signup response: $e', stackTrace);
            rethrow;
          }
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in signup API call: $e', stackTrace);
      rethrow;
    }
  }
}
