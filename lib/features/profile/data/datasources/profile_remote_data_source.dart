import '../../../../core/network/api_service/api_service.dart';
import '../../../../core/network/endpoints/api_endpoints.dart';
import '../../../../core/utils/enumns/api/profile_enums.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> updateProfile({required String name, required String phoneNumber, required String address});
  Future<String> changePassword({required String currentPassword, required String newPassword});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  @override
  Future<ProfileModel> updateProfile({required String name, required String phoneNumber, required String address}) async {
    return await apiService.patchData<ProfileModel>(
      endpoint: ApiEndpoint.profile(ProfileEndpoint.UPDATE_PROFILE),
      data: {'name': name, 'phoneNumber': phoneNumber, 'address': address},
      converter: (response) => ProfileModel.fromJson(response.data['user']),
    );
  }

  @override
  Future<String> changePassword({required String currentPassword, required String newPassword}) async {
    return await apiService.patchData<String>(
      endpoint: ApiEndpoint.profile(ProfileEndpoint.CHANGE_PASSWORD),
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      converter: (response) => response.data['message'] as String,
    );
  }
}
