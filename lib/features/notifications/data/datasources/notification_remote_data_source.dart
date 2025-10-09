import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/network/responce/responce_model.dart';
import '../../../../core/utils/enumns/api/export.dart';
import '../../../../core/utils/typedefs/type_defs.dart';
import '../models/notification_model.dart';
import '../models/device_token_model.dart';
import 'notifications_mock_data_source.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<RegisterDeviceTokenResponseModel> registerDeviceToken(RegisterDeviceTokenRequestModel request);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return NotificationsMockDataSource.getMockNotifications();

    // TODO: Replace with actual API call when backend is ready
    // try {
    //   final response = await apiService.getCollectionData<NotificationModel>(
    //     endpoint: ApiEndpoint.notifications,
    //     converter: (JSON json) => NotificationModel.fromJson(json),
    //   );
    //   return response;
    // } catch (e) {
    //   throw CustomException.fromDioException(e as Exception);
    // }
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
