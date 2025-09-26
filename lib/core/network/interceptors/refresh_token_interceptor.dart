import 'package:dio/dio.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;

  RefreshTokenInterceptor({required Dio dioClient}) : _dio = dioClient;

  String get tokenExpiredException => 'TokenExpiredException';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      if (err.response!.data != null) {
        final responseData = err.response!.data;

        // Check if it's a token expired error based on your API structure
        if (responseData is Map<String, dynamic>) {
          final errorType = responseData['error'];
          final statusCode = responseData['statusCode'];

          // You can customize this logic based on how your API indicates token expiration
          if (errorType == 'Unauthorized' || statusCode == 401) {
            // Handle token expiration
            _dio.close();
          }
        }
      }
    }
    return super.onError(err, handler);
  }

  // Future<String?> _refreshTokenRequest({required DioError dioError, required ErrorInterceptorHandler handler, required Dio tokenDio, required JSON data}) async {
  //   // implement your logic to refresh the token here
  //   return '';
  // }
}
