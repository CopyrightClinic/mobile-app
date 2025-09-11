import '../../constants/pref_constants.dart';
import 'shared_pref_service.dart';

class TokenStorage {
  static final SharedPrefService<String> _sharedPrefService = SharedPrefService<String>();

  static Future<void> saveAccessToken(String accessToken) async {
    await _sharedPrefService.write(SharedPrefConstants.accessTokenKey, accessToken);
  }

  static Future<String?> getAccessToken() async {
    return await _sharedPrefService.read(SharedPrefConstants.accessTokenKey);
  }

  static Future<void> clearAccessToken() async {
    await _sharedPrefService.delete(SharedPrefConstants.accessTokenKey);
  }

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await saveAccessToken(accessToken);
    // await _sharedPrefService.write(SharedPrefConstants.refreshTokenKey, refreshToken);
  }

  static Future<void> clearTokens() async {
    await clearAccessToken();
    // await _sharedPrefService.delete(SharedPrefConstants.refreshTokenKey);
  }
}
