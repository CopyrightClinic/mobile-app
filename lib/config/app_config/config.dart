import 'package:flutter/foundation.dart';

@immutable
class Config {
  const Config._();
  // Configuration settings can be added here
  // For example, API endpoints, feature flags, etc.

  // Example of a configuration setting
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://copy-right-clinic-backend.brainxdemo.com/api/v1');
  static const double designScreenWidth = 375;
  static const double designScreenHeight = 812;
}
