import 'package:dio/dio.dart';

import '../../utils/typedefs/type_defs.dart';
import '../responce/responce_model.dart';

abstract interface class ApiInterface {
  const ApiInterface();

  Future<List<T>> getCollectionData<T>({
    required String endpoint,
    JSON? queryParams,
    JSON? headers,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(JSON responseBody) converter,
  });

  Future<T> getData<T>({
    required String endpoint,
    JSON? queryParams,
    JSON? headers,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(JSON responseBody) converter,
  });

  Future<T> postData<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(ResponseModel<JSON> response) converter,
  });

  Future<T> patchData<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(ResponseModel<JSON> response) converter,
  });

  Future<T> deleteData<T>({
    required String endpoint,
    JSON? data,
    CancelToken? cancelToken,
    bool requiresAuthToken = true,
    required T Function(ResponseModel<JSON> response) converter,
  });

  void cancelRequests({CancelToken? cancelToken});
}
