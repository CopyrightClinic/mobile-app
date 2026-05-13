import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { development, staging, production }

@immutable
class Config {
  const Config._();

  static String get merchantIdentifier =>
      dotenv.env['MERCHANT_IDENTIFIER'] ?? '';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get haroldApiKey => dotenv.env['HAROLD_API_KEY'] ?? '';
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static AppEnvironment get appEnvironment {
    final raw = (dotenv.env['APP_ENV'] ?? 'development').toLowerCase().trim();
    if (raw == 'production' || raw == 'prod') {
      return AppEnvironment.production;
    }
    if (raw == 'staging' || raw == 'stage') {
      return AppEnvironment.staging;
    }
    return AppEnvironment.development;
  }

  static bool get analyticsVerboseDebug =>
      _boolEnv('ANALYTICS_VERBOSE_DEBUG', defaultValue: false);

  static bool get analyticsFirebaseEnabled =>
      _boolEnv('ANALYTICS_FIREBASE_ENABLED', defaultValue: true);

  static bool get analyticsMetaEnabled =>
      _boolEnv('ANALYTICS_META_ENABLED', defaultValue: true);

  static bool get analyticsTikTokEnabled =>
      _boolEnv('ANALYTICS_TIKTOK_ENABLED', defaultValue: true);

  static bool get analyticsMetaAutoLoggingEnabled =>
      _boolEnv('ANALYTICS_META_AUTO_LOG_APP_EVENTS', defaultValue: false);

  static bool get analyticsTikTokDebug =>
      _boolEnv('TIKTOK_ANALYTICS_DEBUG', defaultValue: false);

  static bool get analyticsTikTokVerboseLogs =>
      _boolEnv('TIKTOK_ANALYTICS_VERBOSE_LOGS', defaultValue: false);

  static String get metaAppId => dotenv.env['META_APP_ID'] ?? '';

  static String get metaClientToken => dotenv.env['META_CLIENT_TOKEN'] ?? '';

  static String get tikTokAndroidAppId =>
      dotenv.env['TIKTOK_ANDROID_APP_ID'] ?? '';

  static String get tikTokAndroidSdkKey =>
      dotenv.env['TIKTOK_ANDROID_SDK_KEY'] ?? '';

  static String get tikTokIosAppleAppStoreId =>
      dotenv.env['TIKTOK_IOS_APPLE_APP_STORE_ID'] ?? '';

  static String get tikTokIosTikTokAppId => _firstNonEmptyEnv([
    dotenv.env['TIKTOK_IOS_TIKTOK_APP_ID'],
    dotenv.env['TIKTOK_IOS_APP_ID'],
  ]);

  static String get tikTokIosAccessTokenForSdk => _firstNonEmptyEnv([
    dotenv.env['TIKTOK_IOS_ACCESS_TOKEN'],
    dotenv.env['TIKTOK_IOS_SDK_KEY'],
  ]);

  static bool _boolEnv(String key, {required bool defaultValue}) {
    final raw = dotenv.env[key];
    if (raw == null || raw.isEmpty) return defaultValue;
    final v = raw.toLowerCase().trim();
    return v == '1' || v == 'true' || v == 'yes' || v == 'y';
  }

  static String _firstNonEmptyEnv(Iterable<String?> candidates) {
    for (final raw in candidates) {
      if (raw == null) continue;
      final trimmed = raw.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static const double designScreenWidth = 375;
  static const double designScreenHeight = 812;
}
