import '../models/notification_model.dart';
import 'notifications_mock_data_source.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required apiService});

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
}
