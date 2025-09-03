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
  Future<SendEmailVerificationResponseModel> sendEmailVerification(SendEmailVerificationRequestModel request);
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request);
  Future<VerifyPasswordResetOtpResponseModel> verifyPasswordResetOtp(VerifyOtpRequestModel request);
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request);
  Future<CompleteProfileResponseModel> completeProfile(CompleteProfileRequestModel request);
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

  @override
  Future<SendEmailVerificationResponseModel> sendEmailVerification(SendEmailVerificationRequestModel request) async {
    try {
      final response = await apiService.postData<SendEmailVerificationResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.SEND_EMAIL_VERIFICATION),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          return SendEmailVerificationResponseModel.fromJson(response.data);
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in send email verification API call: $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      final response = await apiService.postData<ForgotPasswordResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.FORGOT_PASSWORD),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          return ForgotPasswordResponseModel.fromJson(response.data);
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in forgot password API call: $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<VerifyPasswordResetOtpResponseModel> verifyPasswordResetOtp(VerifyOtpRequestModel request) async {
    try {
      final response = await apiService.postData<VerifyPasswordResetOtpResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.VERIFY_OTP),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          return VerifyPasswordResetOtpResponseModel.fromJson(response.data);
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in verify password reset OTP API call: $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await apiService.postData<ResetPasswordResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.RESET_PASSWORD),
        data: request.toJson(),
        requiresAuthToken: false,
        converter: (ResponseModel<JSON> response) {
          return ResetPasswordResponseModel.fromJson(response.data);
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in reset password API call: $e', stackTrace);
      rethrow;
    }
  }

  @override
  Future<CompleteProfileResponseModel> completeProfile(CompleteProfileRequestModel request) async {
    try {
      Log.d('AuthRemoteDataSourceImpl', 'Making complete profile API call to: ${ApiEndpoint.auth(AuthEndpoint.COMPLETE_PROFILE)}');
      Log.d('AuthRemoteDataSourceImpl', 'Request data: ${request.toJson()}');

      final response = await apiService.patchData<CompleteProfileResponseModel>(
        endpoint: ApiEndpoint.auth(AuthEndpoint.COMPLETE_PROFILE),
        data: request.toJson(),
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          Log.d('AuthRemoteDataSourceImpl', 'Raw API response: ${response.data}');
          try {
            final completeProfileResponse = CompleteProfileResponseModel.fromJson(response.data);
            Log.d('AuthRemoteDataSourceImpl', 'Parsed complete profile response: ${completeProfileResponse.message}');
            return completeProfileResponse;
          } catch (e, stackTrace) {
            Log.e('AuthRemoteDataSourceImpl', 'Error parsing complete profile response: $e', stackTrace);
            rethrow;
          }
        },
      );
      return response;
    } catch (e, stackTrace) {
      Log.e('AuthRemoteDataSourceImpl', 'Error in complete profile API call: $e', stackTrace);
      rethrow;
    }
  }
}
