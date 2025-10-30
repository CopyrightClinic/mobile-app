import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/enumns/api/export.dart';
import '../../../../core/utils/typedefs/type_defs.dart';
import '../models/device_token_model.dart';
import '../models/notification_list_response_model.dart';
import '../models/mark_all_as_read_response_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationListResponseModel> getNotifications({required String userId, int page = 1, int limit = 20, String? timezone});

  Future<MarkAllAsReadResponseModel> markAllAsRead();

  Future<RegisterDeviceTokenResponseModel> registerDeviceToken(RegisterDeviceTokenRequestModel request);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl({required this.apiService});

  @override
  Future<NotificationListResponseModel> getNotifications({required String userId, int page = 1, int limit = 20, String? timezone}) async {
    try {
      final Map<String, dynamic> headers = {};
      if (timezone != null) headers['timezone'] = timezone;

      final endpoint = '${ApiEndpoint.notifications}/user/$userId';

      final response = await apiService.getData<NotificationListResponseModel>(
        endpoint: endpoint,
        queryParams: {'page': page, 'limit': limit},
        headers: headers.isNotEmpty ? headers : null,
        requiresAuthToken: true,
        converter: (JSON json) => NotificationListResponseModel.fromJson(json),
      );

      return response;
    } catch (e) {
      throw CustomException.fromDioException(e as Exception);
    }
  }

  @override
  Future<MarkAllAsReadResponseModel> markAllAsRead() async {
    try {
      final endpoint = '${ApiEndpoint.notifications}/mark-all-read';
      final response = await apiService.patchData<MarkAllAsReadResponseModel>(
        endpoint: endpoint,
        data: {},
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          return MarkAllAsReadResponseModel.fromJson(response.data);
        },
      );

      return response;
    } catch (e) {
      throw CustomException.fromDioException(e as Exception);
    }
  }

  @override
  Future<RegisterDeviceTokenResponseModel> registerDeviceToken(RegisterDeviceTokenRequestModel request) async {
    try {
      final endpoint = ApiEndpoint.user(UserEndpoint.DEVICE_TOKEN);

      final response = await apiService.postData<RegisterDeviceTokenResponseModel>(
        endpoint: endpoint,
        data: request.toJson(),
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          return RegisterDeviceTokenResponseModel.fromJson(response.data);
        },
      );

      return response;
    } catch (e) {
      throw CustomException.fromDioException(e as Exception);
    }
  }
}
