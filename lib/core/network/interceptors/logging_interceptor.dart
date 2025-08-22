import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../utils/logger/logger.dart';
import '../../utils/typedefs/type_defs.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final httpMethod = options.method.toUpperCase();
    final url = options.baseUrl + options.path;

    Log.o('<-- REQUEST[$httpMethod] => URL: $url');
    Log.o('\tHeaders:');
    options.headers.forEach((k, Object? v) => Log.o('\t\t$k: $v'));
    if (options.queryParameters.isNotEmpty) {
      Log.o('\tqueryParams:');
      options.queryParameters.forEach((k, Object? v) => Log.o('\t\t$k: $v'));
    }
    if (options.data != null) {
      Log.o('\tBody: ${options.data}');
    }
    Log.o('--> END[$httpMethod]');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Log.o(
      '<-- RESPONSE[${response.statusCode}] => URL: ${response.requestOptions.path}',
    );
    if (response.statusCode == 304) {
      Log.o('\tSource: Cache');
    } else {
      Log.o('\tSource: Network');
    }
    Log.o('\tResponse Data: ${response.data}');
    Log.o('<-- END HTTP');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.o('--> ERROR');
    final httpMethod = err.requestOptions.method.toUpperCase();
    final url = err.requestOptions.baseUrl + err.requestOptions.path;

    Log.o('\tMETHOD: $httpMethod');

    Log.o('\tURL: $url');
    if (err.response != null) {
      Log.o('\tStatus code: ${err.response!.statusCode}');
      if (err.response!.data != null) {
        final headers =
            err.response!.data['headers'] as JSON; //API Dependant
        final message = headers['message'] as String; //API Dependant
        final code = headers['code'] as String; //API Dependant
        Log.o('\tException: $code');

        Log.o('\tMessage: $message');
        debugPrint('\tMessage: $message');
        if (headers.containsKey('data')) {
          //API Dependant
          final data = headers['data'] as List<Object?>;
          if (data.isNotEmpty) {
            Log.o('\tData: $data');
            debugPrint('\tData: $data');
          }
        }
      } else {
        Log.o('${err.response!.data}');
      }
    } else if (err.error is SocketException) {
      const message = 'No internet connectivity';
      Log.o('\tException: FetchDataException');
      Log.o('\tMessage: $message');
    } else {
      Log.o('\tUnknown Error');
    }
    Log.o('<-- END ERROR');

    return super.onError(err, handler);
  }
}
