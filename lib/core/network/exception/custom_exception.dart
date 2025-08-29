// ignore_for_file: constant_identifier_names, library_private_types_in_public_api
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum _ExceptionType {
  CancelException,
  ConnectTimeoutException,
  SendTimeoutException,
  ReceiveTimeoutException,
  SocketException,
  FetchDataException,
  FormatException,
  UnrecognizedException,
  ApiException,
  SerializationException,
}

class CustomException implements Exception {
  final String name, message;
  final String? code;
  final int? statusCode;
  final _ExceptionType exceptionType;

  CustomException({this.code, int? statusCode, required this.message, this.exceptionType = _ExceptionType.ApiException})
    : statusCode = statusCode ?? 500,
      name = exceptionType.name;

  factory CustomException.fromDioException(Exception error) {
    try {
      if (error is DioException) {
        switch (error.type) {
          case DioExceptionType.cancel:
            return CustomException(
              exceptionType: _ExceptionType.CancelException,
              statusCode: error.response?.statusCode,
              message: 'Request cancelled prematurely',
            );
          case DioExceptionType.connectionTimeout:
            return CustomException(
              exceptionType: _ExceptionType.ConnectTimeoutException,
              statusCode: error.response?.statusCode,
              message: 'Connection not established',
            );
          case DioExceptionType.sendTimeout:
            return CustomException(
              exceptionType: _ExceptionType.SendTimeoutException,
              statusCode: error.response?.statusCode,
              message: 'Failed to send',
            );
          case DioExceptionType.receiveTimeout:
            return CustomException(
              exceptionType: _ExceptionType.ReceiveTimeoutException,
              statusCode: error.response?.statusCode,
              message: 'Failed to receive',
            );
          case DioExceptionType.badCertificate:
            return CustomException(exceptionType: _ExceptionType.ApiException, statusCode: error.response?.statusCode, message: 'Bad certificate');
          case DioExceptionType.badResponse:
            // For your API, error responses come directly in the response data
            final responseData = error.response?.data;
            if (responseData != null && responseData is Map<String, dynamic>) {
              final message = responseData['message'];
              final statusCode = responseData['statusCode'];
              final errorType = responseData['error'];

              if (message != null) {
                return CustomException(
                  exceptionType: _ExceptionType.ApiException,
                  code: errorType?.toString(),
                  statusCode: statusCode ?? error.response?.statusCode,
                  message: message is List ? message.join(', ') : message.toString(),
                );
              }
            }

            // Fallback for unknown error structure
            return CustomException(
              exceptionType: _ExceptionType.UnrecognizedException,
              statusCode: error.response?.statusCode,
              message: error.response?.statusMessage ?? 'Unknown error',
            );
          case DioExceptionType.connectionError:
            return CustomException(
              exceptionType: _ExceptionType.SocketException,
              statusCode: error.response?.statusCode,
              message: 'Connection error',
            );
          case DioExceptionType.unknown:
            if (error.message != null && error.message!.contains(_ExceptionType.SocketException.name)) {
              return CustomException(
                exceptionType: _ExceptionType.FetchDataException,
                statusCode: error.response?.statusCode,
                message: 'No internet connectivity',
              );
            }
            // Check if it's a token expired error (you can customize this based on your API)
            final responseData = error.response?.data;
            if (responseData != null && responseData is Map<String, dynamic>) {
              final message = responseData['message'];
              final statusCode = responseData['statusCode'];
              final errorType = responseData['error'];

              if (message != null) {
                return CustomException(
                  exceptionType: _ExceptionType.ApiException,
                  code: errorType?.toString(),
                  statusCode: statusCode ?? error.response?.statusCode,
                  message: message is List ? message.join(', ') : message.toString(),
                );
              }
            }

            return CustomException(
              exceptionType: _ExceptionType.UnrecognizedException,
              statusCode: error.response?.statusCode,
              message: error.response?.statusMessage ?? 'Unknown error',
            );
        }
      } else {
        return CustomException(exceptionType: _ExceptionType.UnrecognizedException, message: 'Error unrecognized');
      }
    } on FormatException catch (e) {
      return CustomException(exceptionType: _ExceptionType.FormatException, message: e.message);
    } on Exception catch (_) {
      return CustomException(exceptionType: _ExceptionType.UnrecognizedException, message: 'Error unrecognized');
    }
  }

  factory CustomException.fromParsingException(Exception error) {
    debugPrint('$error');
    return CustomException(exceptionType: _ExceptionType.SerializationException, message: 'Failed to parse network response to model or vice versa');
  }
}
