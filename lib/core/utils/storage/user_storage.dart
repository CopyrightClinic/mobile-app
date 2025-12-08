import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../constants/pref_constants.dart';
import '../logger/logger.dart';
import 'shared_pref_service.dart';

class UserStorage {
  static final SharedPrefService<Map<String, dynamic>> _sharedPrefService = SharedPrefService<Map<String, dynamic>>();

  static Future<void> saveUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      address: user.address,
      role: user.role,
      status: user.status,
      totalSessions: user.totalSessions,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    await _sharedPrefService.write(SharedPrefConstants.userDataKey, userModel.toJson());
  }

  static Future<UserEntity?> getUser() async {
    try {
      final userData = await _sharedPrefService.read(SharedPrefConstants.userDataKey);
      Log.d('userData', userData.toString());
      if (userData != null) {
        return UserModel.fromJson(userData).toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    await _sharedPrefService.delete(SharedPrefConstants.userDataKey);
  }

  static Future<bool> hasUser() async {
    final userData = await _sharedPrefService.read(SharedPrefConstants.userDataKey);
    return userData != null;
  }
}
