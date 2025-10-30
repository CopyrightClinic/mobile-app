import 'dart:developer' as developer;
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
      developer.log('📡 [Notifications API] Fetching notifications', name: 'NotificationAPI');
      developer.log('Request Details - userId: $userId, page: $page, limit: $limit, timezone: $timezone', name: 'NotificationAPI');

      final Map<String, dynamic> headers = {};
      if (timezone != null) headers['timezone'] = timezone;

      final endpoint = '${ApiEndpoint.notifications}/user/$userId';
      developer.log('Endpoint: $endpoint', name: 'NotificationAPI');
      developer.log('Query Params: {page: $page, limit: $limit}', name: 'NotificationAPI');
      developer.log('Headers: $headers', name: 'NotificationAPI');

      final response = await apiService.getData<NotificationListResponseModel>(
        endpoint: endpoint,
        queryParams: {'page': page, 'limit': limit},
        headers: headers.isNotEmpty ? headers : null,
        requiresAuthToken: true,
        converter: (JSON json) => NotificationListResponseModel.fromJson(json),
      );

      developer.log(
        '✅ [Notifications API] Success - Total: ${response.total}, Page: ${response.page}, Items: ${response.data.length}',
        name: 'NotificationAPI',
      );

      return response;
    } catch (e) {
      developer.log('❌ [Notifications API] Error: $e', name: 'NotificationAPI', error: e);
      throw CustomException.fromDioException(e as Exception);
    }
  }

  @override
  Future<MarkAllAsReadResponseModel> markAllAsRead() async {
    try {
      developer.log('📡 [Notifications API] Marking all notifications as read', name: 'NotificationAPI');

      final endpoint = '${ApiEndpoint.notifications}/mark-all-read';
      developer.log('Endpoint: $endpoint', name: 'NotificationAPI');

      final response = await apiService.patchData<MarkAllAsReadResponseModel>(
        endpoint: endpoint,
        data: {},
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          return MarkAllAsReadResponseModel.fromJson(response.data);
        },
      );

      developer.log('✅ [Notifications API] Mark all as read success - Marked count: ${response.markedCount}', name: 'NotificationAPI');

      return response;
    } catch (e) {
      developer.log('❌ [Notifications API] Mark all as read error: $e', name: 'NotificationAPI', error: e);
      throw CustomException.fromDioException(e as Exception);
    }
  }

  @override
  Future<RegisterDeviceTokenResponseModel> registerDeviceToken(RegisterDeviceTokenRequestModel request) async {
    try {
      developer.log('📡 [Notifications API] Registering device token', name: 'NotificationAPI');
      developer.log('Request data: ${request.toJson()}', name: 'NotificationAPI');

      final endpoint = ApiEndpoint.user(UserEndpoint.DEVICE_TOKEN);
      developer.log('Endpoint: $endpoint', name: 'NotificationAPI');

      final response = await apiService.postData<RegisterDeviceTokenResponseModel>(
        endpoint: endpoint,
        data: request.toJson(),
        requiresAuthToken: true,
        converter: (ResponseModel<JSON> response) {
          return RegisterDeviceTokenResponseModel.fromJson(response.data);
        },
      );

      developer.log('✅ [Notifications API] Device token registration success', name: 'NotificationAPI');

      return response;
    } catch (e) {
      developer.log('❌ [Notifications API] Device token registration error: $e', name: 'NotificationAPI', error: e);
      throw CustomException.fromDioException(e as Exception);
    }
  }
}
