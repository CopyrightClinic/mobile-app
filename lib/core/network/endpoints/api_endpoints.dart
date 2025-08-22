// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

import '../../../config/app_config/config.dart';

@immutable
class ApiEndpoint {
  const ApiEndpoint._();

  static const baseUrl = Config.baseUrl;

  static String auth(AuthEndpoint endpoint) {
    const path = '/auth';
    switch (endpoint) {
      case AuthEndpoint.REGISTER:
        return '$path/register';
      case AuthEndpoint.LOGIN:
        return '$path/login';
      case AuthEndpoint.REFRESH_TOKEN:
        return '$path/refresh-token';
      case AuthEndpoint.CHANGE_PASSWORD:
        return '$path/change-password';
      case AuthEndpoint.FORGOT_PW_SEND_OTP:
        return '$path/forgot/send-otp';
      case AuthEndpoint.FORGOT_PW_VERIFY_OTP:
        return '$path/forgot/verify-otp';
      case AuthEndpoint.FORGOT_PW_RESET_PASSWORD:
        return '$path/forgot/reset-password';
    }
  }

  static String students(
    StudentEndpoint endpoint, {
    String? erp,
    int? extendedResourceId,
  }) {
    const path = '/students';
    switch (endpoint) {
      case StudentEndpoint.BASE:
        return path;
      case StudentEndpoint.BY_ERP:
        {
          assert(erp != null, 'studentErp is required for BY_ERP endpoint');
          return '$path/$erp';
        }
      case StudentEndpoint.ORGANIZED_ACTIVITIES:
        {
          assert(
            erp != null,
            'studentErp is required for ORGANIZED_ACTIVITIES endpoint',
          );
          return '$path/$erp/organized-activities';
        }
      case StudentEndpoint.ATTENDED_ACTIVITIES:
        {
          assert(
            erp != null,
            'studentErp is required for ATTENDED_ACTIVITIES endpoint',
          );
          return '$path/$erp/attended-activities';
        }
      case StudentEndpoint.SAVED_ACTIVITIES_BASE:
        {
          assert(
            erp != null,
            'studentErp is required for SAVED_ACTIVITIES_BASE endpoint',
          );
          return '$path/$erp/saved-activities';
        }
      case StudentEndpoint.SAVED_ACTIVITIES_BY_ID:
        {
          assert(
            erp != null,
            'studentErp is required for SAVED_ACTIVITIES_BY_ID endpoint',
          );
          assert(
            extendedResourceId != null,
            'extendedResourceId is required for SAVED_ACTIVITIES_BY_ID endpoint',
          );
          return '$path/$erp/saved-activities/$extendedResourceId';
        }
    }
  }

  static String studentConnections(
    StudentConnectionEndpoint endpoint, {
    int? id,
  }) {
    const path = '/student-connections';
    switch (endpoint) {
      case StudentConnectionEndpoint.BASE:
        return path;
      case StudentConnectionEndpoint.REQUESTS:
        return '$path/requests';
      case StudentConnectionEndpoint.BY_ID:
        {
          assert(
            id != null,
            'studentConnectionId is required for BY_ID endpoint',
          );
          return '$path/$id';
        }
    }
  }

  static String interests(InterestEndpoint endpoint) {
    const path = '/interests';
    switch (endpoint) {
      case InterestEndpoint.BASE:
        return path;
    }
  }
}

enum AuthEndpoint {
  REGISTER,

  LOGIN,

  REFRESH_TOKEN,

  CHANGE_PASSWORD,

  FORGOT_PW_RESET_PASSWORD,

  FORGOT_PW_SEND_OTP,

  FORGOT_PW_VERIFY_OTP,
}

enum StudentEndpoint {
  BASE,

  BY_ERP,

  ORGANIZED_ACTIVITIES,

  SAVED_ACTIVITIES_BASE,

  SAVED_ACTIVITIES_BY_ID,

  ATTENDED_ACTIVITIES,
}

enum StudentConnectionEndpoint { BASE, REQUESTS, BY_ID }

enum InterestEndpoint { BASE }
