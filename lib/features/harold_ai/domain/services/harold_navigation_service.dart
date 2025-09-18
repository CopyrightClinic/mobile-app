// ignore_for_file: use_build_context_synchronously

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/storage/token_storage.dart';
import '../../../../core/utils/storage/shared_pref_service.dart';

class HaroldNavigationService {
  static const String _haroldResultKey = 'harold_pending_result';
  static const String _haroldQueryKey = 'harold_pending_query';
  static final SharedPrefService<String> _prefService = SharedPrefService<String>();

  static Future<bool> isUserAuthenticated() async {
    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> storePendingResult(bool isSuccess, String query) async {
    await _prefService.write(_haroldResultKey, isSuccess ? 'success' : 'failure');
    await _prefService.write(_haroldQueryKey, query);
  }

  static Future<String?> getPendingResult() async {
    final result = await _prefService.read(_haroldResultKey);
    if (result != null) {
      await _prefService.delete(_haroldResultKey);
    }
    return result;
  }

  static Future<String?> getPendingQuery() async {
    final query = await _prefService.read(_haroldQueryKey);
    if (query != null) {
      await _prefService.delete(_haroldQueryKey);
    }
    return query;
  }

  static Future<Map<String, String?>> getPendingResultAndQuery() async {
    final result = await _prefService.read(_haroldResultKey);
    final query = await _prefService.read(_haroldQueryKey);

    if (result != null) {
      await _prefService.delete(_haroldResultKey);
    }
    if (query != null) {
      await _prefService.delete(_haroldQueryKey);
    }

    return {'result': result, 'query': query};
  }

  static void handleHaroldResult({required BuildContext context, required bool isSuccess, required bool isUserAuthenticated, required String query}) {
    if (isUserAuthenticated) {
      if (isSuccess) {
        context.push(AppRoutes.haroldSuccessRouteName, extra: {'fromAuthFlow': false, 'query': query});
      } else {
        context.push(AppRoutes.haroldFailedRouteName, extra: {'fromAuthFlow': false, 'query': query});
      }
    } else {
      storePendingResult(isSuccess, query).then((_) {
        context.push(AppRoutes.haroldSignupRouteName);
      });
    }
  }

  static void handlePostAuthNavigation(BuildContext context) {
    getPendingResultAndQuery().then((data) {
      final pendingResult = data['result'];
      final pendingQuery = data['query'];

      if (pendingResult != null) {
        if (pendingResult == 'success') {
          context.go(AppRoutes.haroldSuccessRouteName, extra: {'fromAuthFlow': true, 'query': pendingQuery});
        } else {
          context.go(AppRoutes.haroldFailedRouteName, extra: {'fromAuthFlow': true, 'query': pendingQuery});
        }
      } else {
        context.go(AppRoutes.homeRouteName);
      }
    });
  }
}
