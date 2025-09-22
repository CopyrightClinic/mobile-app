// ignore_for_file: constant_identifier_names, library_private_types_in_public_api
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_strings.dart';
import '../models/api_error_model.dart';

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
              message: AppStrings.failedToSend,
            );
          case DioExceptionType.receiveTimeout:
            return CustomException(
              exceptionType: _ExceptionType.ReceiveTimeoutException,
              statusCode: error.response?.statusCode,
              message: AppStrings.failedToReceive,
            );
          case DioExceptionType.badCertificate:
            return CustomException(exceptionType: _ExceptionType.ApiException, statusCode: error.response?.statusCode, message: 'Bad certificate');
          case DioExceptionType.badResponse:
            final responseData = error.response?.data;
            if (responseData != null) {
              try {
                final apiError = ApiErrorModel.fromResponse(responseData);
                return CustomException(
                  exceptionType: _ExceptionType.ApiException,
                  code: apiError.error,
                  statusCode: apiError.statusCode,
                  message: apiError.message,
                );
              } catch (e) {
                debugPrint('Failed to parse API error: $e');
              }
            }

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
            final responseData = error.response?.data;
            if (responseData != null) {
              try {
                final apiError = ApiErrorModel.fromResponse(responseData);
                return CustomException(
                  exceptionType: _ExceptionType.ApiException,
                  code: apiError.error,
                  statusCode: apiError.statusCode,
                  message: apiError.message,
                );
              } catch (e) {
                debugPrint('Failed to parse API error: $e');
              }
            }

            return CustomException(
              exceptionType: _ExceptionType.UnrecognizedException,
              statusCode: error.response?.statusCode,
              message: error.response?.statusMessage ?? 'Unknown error',
            );
        }
      } else {
        return CustomException(exceptionType: _ExceptionType.UnrecognizedException, message: AppStrings.errorUnrecognized);
      }
    } on FormatException catch (e) {
      return CustomException(exceptionType: _ExceptionType.FormatException, message: e.message);
    } on Exception catch (_) {
      return CustomException(exceptionType: _ExceptionType.UnrecognizedException, message: AppStrings.errorUnrecognized);
    }
  }

  factory CustomException.fromParsingException(Exception error) {
    debugPrint('$error');
    return CustomException(exceptionType: _ExceptionType.SerializationException, message: AppStrings.failedToParseNetworkResponse);
  }
}
