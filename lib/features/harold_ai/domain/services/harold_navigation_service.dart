// ignore_for_file: use_build_context_synchronously

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/storage/token_storage.dart';
import '../../presentation/pages/params/harold_success_screen_params.dart';
import '../../presentation/pages/params/harold_failed_screen_params.dart';

class HaroldNavigationService {
  static HaroldNavigationService? _instance;

  HaroldNavigationService._();

  factory HaroldNavigationService() {
    _instance ??= HaroldNavigationService._();
    return _instance!;
  }

  String? _pendingResult;
  String? _pendingQuery;

  static Future<bool> isUserAuthenticated() async {
    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  void storePendingResult(bool isSuccess, String query) {
    _pendingResult = isSuccess ? 'success' : 'failure';
    _pendingQuery = query;
  }

  String? getPendingResult() {
    final result = _pendingResult;
    if (result != null) {
      _pendingResult = null;
    }
    return result;
  }

  String? getPendingQuery() {
    final query = _pendingQuery;
    if (query != null) {
      _pendingQuery = null;
    }
    return query;
  }

  Map<String, String?> getPendingResultAndQuery() {
    final result = _pendingResult;
    final query = _pendingQuery;

    if (result != null) {
      _pendingResult = null;
    }
    if (query != null) {
      _pendingQuery = null;
    }

    return {'result': result, 'query': query};
  }

  static void handleHaroldResult({required BuildContext context, required bool isSuccess, required bool isUserAuthenticated, required String query}) {
    if (isUserAuthenticated) {
      if (isSuccess) {
        context.push(AppRoutes.haroldSuccessRouteName, extra: HaroldSuccessScreenParams(fromAuthFlow: false, query: query));
      } else {
        context.push(AppRoutes.haroldFailedRouteName, extra: HaroldFailedScreenParams(fromAuthFlow: false, query: query));
      }
    } else {
      HaroldNavigationService().storePendingResult(isSuccess, query);
      context.push(AppRoutes.haroldSignupRouteName);
    }
  }

  static void handlePostAuthNavigation(BuildContext context) {
    final data = HaroldNavigationService().getPendingResultAndQuery();
    final pendingResult = data['result'];
    final pendingQuery = data['query'];

    if (pendingResult != null) {
      if (pendingResult == 'success') {
        context.go(AppRoutes.haroldSuccessRouteName, extra: HaroldSuccessScreenParams(fromAuthFlow: true, query: pendingQuery));
      } else {
        context.go(AppRoutes.haroldFailedRouteName, extra: HaroldFailedScreenParams(fromAuthFlow: true, query: pendingQuery));
      }
    } else {
      context.go(AppRoutes.homeRouteName);
    }
  }
}
