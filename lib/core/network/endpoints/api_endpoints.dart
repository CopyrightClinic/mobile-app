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
      case AuthEndpoint.SEND_EMAIL_VERIFICATION:
        return '$path/send-email-verification';
      case AuthEndpoint.FORGOT_PASSWORD:
        return '$path/forgot-password';
      case AuthEndpoint.VERIFY_OTP:
        return '$path/verify-otp';
      case AuthEndpoint.RESET_PASSWORD:
        return '$path/reset-password';
      case AuthEndpoint.COMPLETE_PROFILE:
        return '$path/complete-profile';
    }
  }

  /// Payment endpoints
  ///
  /// Provides payment operations:
  static String payment(PaymentEndpoint endpoint) {
    const path = '/payment-methods';
    switch (endpoint) {
      case PaymentEndpoint.PAYMENT_METHODS:
        return path;
    }
  }
}
