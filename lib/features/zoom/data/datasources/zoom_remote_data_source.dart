import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/utils/enumns/api/zoom_enums.dart';
import '../models/zoom_meeting_credentials_model.dart';

abstract class ZoomRemoteDataSource {
  Future<ZoomMeetingCredentialsModel> getMeetingCredentials(String meetingId);
}

class ZoomRemoteDataSourceImpl implements ZoomRemoteDataSource {
  final ApiService apiService;

  ZoomRemoteDataSourceImpl({required this.apiService});

  @override
  Future<ZoomMeetingCredentialsModel> getMeetingCredentials(String meetingId) async {
    return await apiService.postData<ZoomMeetingCredentialsModel>(
      endpoint: ApiEndpoint.zoom(ZoomEndpoint.SDK_TOKEN),
      data: {'sessionId': meetingId},
      converter: (response) => ZoomMeetingCredentialsModel.fromJson(response.data),
    );
  }
}
