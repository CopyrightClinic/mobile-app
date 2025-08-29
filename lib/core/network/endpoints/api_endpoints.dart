// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import '../../../config/app_config/config.dart';
import '../../utils/enumns/api/export.dart';

@immutable
class ApiEndpoint {
  const ApiEndpoint._();

  static const baseUrl = Config.baseUrl;

  /// Authentication endpoints
  ///
  /// Provides authentication operations:
  /// - LOGIN: User login
  /// - SIGNUP: User registration
  /// - VERIFY_EMAIL: Email verification
  static String auth(AuthEndpoint endpoint) {
    const path = '/auth';
    switch (endpoint) {
      case AuthEndpoint.SIGNUP:
        return '$path/signup';
      case AuthEndpoint.LOGIN:
        return '$path/login';
      case AuthEndpoint.VERIFY_EMAIL:
        return '$path/verify-email';
    }
  }
}
