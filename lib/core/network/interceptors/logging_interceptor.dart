import 'dart:io';
import 'package:dio/dio.dart';
import '../../utils/logger/logger.dart';
import '../../utils/typedefs/type_defs.dart';

class LoggingInterceptor extends Interceptor {
  static const String _separator = '────────────────────────────────────────────────────────────────────────────────────────────────────────────────';
  static const String _indent = '  ';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final httpMethod = options.method.toUpperCase();
    final url = options.baseUrl + options.path;
    final timestamp = DateTime.now().toIso8601String();

    Log.o('🚀 HTTP REQUEST');
    Log.o(_separator);
    Log.o('${_indent}Method: $httpMethod');
    Log.o('${_indent}URL: $url');
    Log.o('${_indent}Timestamp: $timestamp');

    if (options.headers.isNotEmpty) {
      Log.o('${_indent}Headers:');
      options.headers.forEach((key, value) {
        Log.o('$_indent$_indent• $key: $value');
      });
    }

    if (options.queryParameters.isNotEmpty) {
      Log.o('$_indent Query Parameters:');
      options.queryParameters.forEach((key, value) {
        Log.o('$_indent$_indent • $key: $value');
      });
    }

    if (options.data != null) {
      Log.o('$_indent Request Body:');
      Log.o('$_indent$_indent ${options.data}');
    }

    Log.o(_separator);
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode ?? 0;
    final url = response.requestOptions.path;
    final timestamp = DateTime.now().toIso8601String();
    final source = statusCode == 304 ? 'Cache' : 'Network';
    final statusEmoji = _getStatusEmoji(statusCode);

    Log.o('✅ HTTP RESPONSE');
    Log.o(_separator);
    Log.o('$_indent Status: $statusEmoji $statusCode');
    Log.o('$_indent URL: $url');
    Log.o('$_indent Source: $source');
    Log.o('$_indent Timestamp: $timestamp');
    Log.o('$_indent Response Data:');
    Log.o('$_indent$_indent ${response.data}');
    Log.o(_separator);

    return super.onResponse(response, handler);
  }

  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '🔄';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '❌';
    return '❓';
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final httpMethod = err.requestOptions.method.toUpperCase();
    final url = err.requestOptions.baseUrl + err.requestOptions.path;
    final timestamp = DateTime.now().toIso8601String();
    final errorType = _getErrorType(err);

    Log.o('❌ HTTP ERROR');
    Log.o(_separator);
    Log.o('$_indent Method: $httpMethod');
    Log.o('$_indent URL: $url');
    Log.o('$_indent Error Type: $errorType');
    Log.o('$_indent Timestamp: $timestamp');

    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      Log.o('$_indent Status Code: $statusCode');

      if (err.response!.data != null) {
        try {
          final responseData = err.response!.data;
          if (responseData is JSON) {
            if (responseData.containsKey('headers')) {
              final headers = responseData['headers'] as JSON;
              Log.o('$_indent Error Details:');
              Log.o('$_indent$_indent • Code: ${headers['code'] ?? 'N/A'}');
              Log.o('$_indent$_indent • Message: ${headers['message'] ?? 'N/A'}');

              if (headers.containsKey('data')) {
                final data = headers['data'];
                if (data is List && data.isNotEmpty) {
                  Log.o('$_indent$_indent • Data: $data');
                }
              }
            } else {
              Log.o('$_indent Response Data: ${err.response!.data}');
            }
          } else {
            Log.o('$_indent Response Data: ${err.response!.data}');
          }
        } catch (e) {
          Log.o('$_indent Response Data: ${err.response!.data}');
        }
      }
    } else if (err.error is SocketException) {
      Log.o('$_indent Network Error: No internet connectivity');
      Log.o('$_indent Exception: SocketException');
    } else {
      Log.o('$_indent Unknown Error: ${err.error}');
    }

    Log.o(_separator);
    return super.onError(err, handler);
  }

  String _getErrorType(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection Timeout';
      case DioExceptionType.sendTimeout:
        return 'Send Timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive Timeout';
      case DioExceptionType.badResponse:
        return 'Bad Response';
      case DioExceptionType.cancel:
        return 'Request Cancelled';
      case DioExceptionType.connectionError:
        return 'Connection Error';
      case DioExceptionType.unknown:
        return 'Unknown Error';
      default:
        return 'Other Error';
    }
  }
}
