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

  /// Sessions endpoints
  ///
  /// Provides session operations:
  static String sessions(SessionsEndpoint endpoint, {String? sessionId}) {
    switch (endpoint) {
      case SessionsEndpoint.USER_SESSIONS:
        return '/user/sessions';
      case SessionsEndpoint.SESSION_DETAILS:
        return '/user/session-details';
      case SessionsEndpoint.SESSION_FEEDBACK:
        return '/user/session/feedback';
      case SessionsEndpoint.SESSIONS_AVAILABILITY:
        return '/sessions-availability';
      case SessionsEndpoint.BOOK_SESSION:
        return '/session-requests/book-session';
      case SessionsEndpoint.SESSION_SUMMARY:
        return '/session-summary';
      case SessionsEndpoint.CANCEL_SESSION:
        return '/sessions/${sessionId ?? ''}/cancel';
      case SessionsEndpoint.EXTEND_SESSION:
        return '/sessions/${sessionId ?? ''}/request-extension';
    }
  }

  /// Profile endpoints
  ///
  /// Provides profile operations:
  static String profile(ProfileEndpoint endpoint) {
    const path = '/user';
    switch (endpoint) {
      case ProfileEndpoint.CHANGE_PASSWORD:
        return '$path/password';
      case ProfileEndpoint.UPDATE_PROFILE:
        return '$path/profile';
      case ProfileEndpoint.DELETE_PROFILE:
        return path;
    }
  }

  static String harold(HaroldEndpoint endpoint) {
    const path = '/copyright-evaluation';
    switch (endpoint) {
      case HaroldEndpoint.EVALUATE:
        return '$path/evaluate';
    }
  }

  /// Notifications endpoints
  ///
  /// Provides notification operations:
  static const String notifications = '/notifications';

  /// User endpoints
  ///
  /// Provides user-related operations:
  static String user(UserEndpoint endpoint) {
    const path = '/user';
    switch (endpoint) {
      case UserEndpoint.DEVICE_TOKEN:
        return '$path/device-token';
    }
  }

  static String zoom(ZoomEndpoint endpoint) {
    const path = '/zoom/mobile';
    switch (endpoint) {
      case ZoomEndpoint.SDK_TOKEN:
        return '$path/sdk-token';
    }
  }
}
