import 'package:dio/dio.dart';

import '../../utils/storage/token_storage.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor() : super();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra.containsKey('requiresAuthToken')) {
      if (options.extra['requiresAuthToken'] == true) {
        final token = await TokenStorage.getAccessToken();
        options.headers.addAll(<String, Object?>{'Authorization': 'Bearer $token'});
      }
      options.extra.remove('requiresAuthToken');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // For your API, we don't need to check headers since the response structure is different
    // Just pass through the response
    return handler.next(response);
  }
}
