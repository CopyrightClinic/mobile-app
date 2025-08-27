import '../../constants/pref_constants.dart';
import 'shared_pref_service.dart';

class TokenStorage {
  static final SharedPrefService<String> _sharedPrefService = SharedPrefService<String>();

  /// Save access token to local storage
  static Future<void> saveAccessToken(String accessToken) async {
    await _sharedPrefService.write(SharedPrefConstants.accessTokenKey, accessToken);
  }

  /// Get access token from local storage
  static Future<String?> getAccessToken() async {
    return await _sharedPrefService.read(SharedPrefConstants.accessTokenKey);
  }

  /// Clear access token from local storage
  static Future<void> clearAccessToken() async {
    await _sharedPrefService.delete(SharedPrefConstants.accessTokenKey);
  }

  /// Legacy method for backward compatibility
  /// In the future, when you add refresh token functionality, you can expand this
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await saveAccessToken(accessToken);
    // TODO: Implement refresh token storage when needed
    // await _sharedPrefService.write(SharedPrefConstants.refreshTokenKey, refreshToken);
  }

  /// Legacy method for backward compatibility
  static Future<void> clearTokens() async {
    await clearAccessToken();
    // TODO: Implement refresh token clearing when needed
    // await _sharedPrefService.delete(SharedPrefConstants.refreshTokenKey);
  }
}
