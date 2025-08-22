import 'package:dio/dio.dart';

import '../../utils/typedefs/type_defs.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;

  RefreshTokenInterceptor({required Dio dioClient}) : _dio = dioClient;

  String get tokenExpiredException => 'TokenExpiredException';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      if (err.response!.data != null) {
        final headers = err.response!.data['headers'] as JSON;

        final code = headers['code'] as String;
        if (code == tokenExpiredException) {
          _dio.close();
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
