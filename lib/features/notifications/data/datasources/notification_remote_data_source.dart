import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/enumns/api/export.dart';
import '../../../../core/utils/typedefs/type_defs.dart';
import '../models/notification_model.dart';
import '../models/device_token_model.dart';
import '../models/notification_list_response_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationListResponseModel> getNotifications({required String userId, int page = 1, int limit = 20});

  Future<NotificationModel> markAsRead(String notificationId);

  Future<RegisterDeviceTokenResponseModel> registerDeviceToken(RegisterDeviceTokenRequestModel request);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl({required this.apiService});

  @override
  Future<NotificationListResponseModel> getNotifications({required String userId, int page = 1, int limit = 20}) async {
    try {
      final response = await apiService.getData<NotificationListResponseModel>(
        endpoint: '${ApiEndpoint.notifications}/user/$userId',
        queryParams: {'page': page, 'limit': limit},
        requiresAuthToken: true,
        converter: (JSON json) => NotificationListResponseModel.fromJson(json),
      );
      return response;
    } catch (e) {
      throw CustomException.fromDioException(e as Exception);
    }
  }

  @override
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      final response = await apiService.patchData<NotificationModel>(
        endpoint: '${ApiEndpoint.notifications}/$notificationId/read',
        data: {},
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          return NotificationModel.fromJson(response.data);
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
      final response = await apiService.postData<RegisterDeviceTokenResponseModel>(
        endpoint: ApiEndpoint.user(UserEndpoint.DEVICE_TOKEN),
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
