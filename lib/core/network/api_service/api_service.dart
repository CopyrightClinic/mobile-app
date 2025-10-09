import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../../utils/typedefs/type_defs.dart';
import '../dio_service.dart';
import '../exception/custom_exception.dart';
import '../responce/responce_model.dart';
import 'api_service_interface.dart';

class ApiService implements ApiInterface {
  late final DioService _dioService;

  ApiService(DioService dioService) : _dioService = dioService;

  @override
  Future<List<T>> getCollectionData<T>({
    required String endpoint,
    JSON? queryParams,
    JSON? headers,
    CancelToken? cancelToken,
    CachePolicy? cachePolicy,
    int? cacheAgeDays,
    bool requiresAuthToken = true,
    required T Function(JSON responseBody) converter,
  }) async {
    List<Object?> body;

    try {
      final data = await _dioService.get<JSON>(
        endpoint: endpoint,
        cacheOptions: _dioService.globalCacheOptions?.copyWith(
          policy: cachePolicy,
          maxStale: cacheAgeDays != null ? Duration(days: cacheAgeDays) : null,
        ),
        options: Options(extra: <String, Object?>{'requiresAuthToken': requiresAuthToken}, headers: headers),
        queryParams: queryParams,
        cancelToken: cancelToken,
      );

      final responseData = data.data;
      if (responseData.containsKey('data') && responseData['data'] is List) {
        body = responseData['data'] as List<Object?>;
      } else {
        throw CustomException.fromParsingException(Exception('Expected response to contain data array'));
      }
    } on Exception catch (ex) {
      throw CustomException.fromDioException(ex);
    }

    try {
      return body.map((dataMap) => converter(dataMap! as JSON)).toList();
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  Future<T> getData<T>({
    required String endpoint,
    JSON? queryParams,
    JSON? headers,
    CancelToken? cancelToken,
    CachePolicy? cachePolicy,
    int? cacheAgeDays,
    bool requiresAuthToken = true,
    required T Function(JSON response) converter,
  }) async {
    JSON body;
    try {
      final options = Options(extra: <String, Object?>{'requiresAuthToken': requiresAuthToken}, headers: headers);

      final data = await _dioService.get<JSON>(
        endpoint: endpoint,
        queryParams: queryParams,
        cacheOptions: _dioService.globalCacheOptions?.copyWith(
          policy: cachePolicy,
          maxStale: cacheAgeDays != null ? Duration(days: cacheAgeDays) : null,
        ),
        options: options,
        cancelToken: cancelToken,
      );

      body = data.data;
    } on Exception catch (ex) {
      throw CustomException.fromDioException(ex);
    }

    try {
      return converter(body);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  Future<T> postData<T>({
    required String endpoint,
    required JSON data,
    JSON? headers,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(ResponseModel<JSON> response) converter,
  }) async {
    ResponseModel<JSON> response;

    try {
      response = await _dioService.post<JSON>(
        endpoint: endpoint,
        data: data,
        options: Options(extra: <String, Object?>{'requiresAuthToken': requiresAuthToken}, headers: headers),
        cancelToken: cancelToken,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(ex);
    }

    try {
      return converter(response);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  Future<T> patchData<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(ResponseModel<JSON> response) converter,
  }) async {
    ResponseModel<JSON> response;

    try {
      response = await _dioService.patch<JSON>(
        endpoint: endpoint,
        data: data,
        options: Options(extra: <String, Object?>{'requiresAuthToken': requiresAuthToken}),
        cancelToken: cancelToken,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(ex);
    }

    try {
      return converter(response);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  Future<T> deleteData<T>({
    required String endpoint,
    JSON? data,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(ResponseModel<JSON> response) converter,
  }) async {
    ResponseModel<JSON> response;

    try {
      response = await _dioService.delete<JSON>(
        endpoint: endpoint,
        data: data,
        options: Options(extra: <String, Object?>{'requiresAuthToken': requiresAuthToken}),
        cancelToken: cancelToken,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(ex);
    }

    try {
      return converter(response);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(ex);
    }
  }

  @override
  void cancelRequests({CancelToken? cancelToken}) {
    _dioService.cancelRequests(cancelToken: cancelToken);
  }
}
