// ignore_for_file: use_build_context_synchronously

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/storage/token_storage.dart';
import '../../../../core/utils/storage/shared_pref_service.dart';

class HaroldNavigationService {
  static const String _haroldResultKey = 'harold_pending_result';
  static final SharedPrefService<String> _prefService = SharedPrefService<String>();

  static Future<bool> isUserAuthenticated() async {
    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> storePendingResult(bool isSuccess) async {
    await _prefService.write(_haroldResultKey, isSuccess ? 'success' : 'failure');
  }

  static Future<String?> getPendingResult() async {
    final result = await _prefService.read(_haroldResultKey);
    if (result != null) {
      await _prefService.delete(_haroldResultKey);
    }
    return result;
  }

  static void handleHaroldResult({required BuildContext context, required bool isSuccess, required bool isUserAuthenticated}) {
    if (isUserAuthenticated) {
      if (isSuccess) {
        context.push(AppRoutes.haroldSuccessRouteName, extra: {'fromAuthFlow': false});
      } else {
        context.push(AppRoutes.haroldFailedRouteName, extra: {'fromAuthFlow': false});
      }
    } else {
      storePendingResult(isSuccess).then((_) {
        context.push(AppRoutes.haroldSignupRouteName);
      });
    }
  }

  static void handlePostAuthNavigation(BuildContext context) {
    getPendingResult().then((pendingResult) {
      if (pendingResult != null) {
        if (pendingResult == 'success') {
          context.go(AppRoutes.haroldSuccessRouteName, extra: {'fromAuthFlow': true});
        } else {
          context.go(AppRoutes.haroldFailedRouteName, extra: {'fromAuthFlow': true});
        }
      } else {
        context.go(AppRoutes.homeRouteName);
      }
    });
  }
}
