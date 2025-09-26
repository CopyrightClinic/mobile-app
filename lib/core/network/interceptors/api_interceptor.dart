import 'package:dio/dio.dart';

import '../../utils/storage/token_storage.dart';
import '../../../config/app_config/config.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor() : super();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('/copyright-evaluation')) {
      options.headers.addAll(<String, Object?>{'x-api-key': Config.haroldApiKey});
    }

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
    return handler.next(response);
  }
}
