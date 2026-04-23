import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/storage/token_storage.dart';
import '../entities/consultation_fee.dart';
import '../../presentation/pages/params/harold_failed_screen_params.dart';
import '../../presentation/pages/params/harold_intake_questions_screen_params.dart';

class HaroldNavigationService {
  static HaroldNavigationService? _instance;

  HaroldNavigationService._();

  factory HaroldNavigationService() {
    _instance ??= HaroldNavigationService._();
    return _instance!;
  }

  String? _pendingResult;
  String? _pendingQuery;
  ConsultationFee? _pendingFee;
  String? _pendingUserType;
  String? _pendingEvaluationId;

  static Future<bool> isUserAuthenticated() async {
    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  void storePendingResult(bool isSuccess, String query, ConsultationFee? fee, String? userType, String? evaluationId) {
    _pendingResult = isSuccess ? 'success' : 'failure';
    _pendingQuery = query;
    _pendingFee = fee;
    _pendingUserType = userType;
    _pendingEvaluationId = evaluationId;
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

  ConsultationFee? getPendingFee() {
    final fee = _pendingFee;
    if (fee != null) {
      _pendingFee = null;
    }
    return fee;
  }

  Map<String, dynamic> getPendingResultAndQuery() {
    final result = _pendingResult;
    final query = _pendingQuery;
    final fee = _pendingFee;
    final userType = _pendingUserType;
    final evaluationId = _pendingEvaluationId;

    if (result != null) {
      _pendingResult = null;
    }
    if (query != null) {
      _pendingQuery = null;
    }
    if (fee != null) {
      _pendingFee = null;
    }
    if (userType != null) {
      _pendingUserType = null;
    }
    if (evaluationId != null) {
      _pendingEvaluationId = null;
    }

    return {'result': result, 'query': query, 'fee': fee, 'userType': userType, 'evaluationId': evaluationId};
  }

  static void handleHaroldResult({
    required BuildContext context,
    required bool isSuccess,
    required bool isUserAuthenticated,
    required String query,
    ConsultationFee? fee,
    String? userType,
    String? evaluationId,
  }) {
    if (isUserAuthenticated) {
      if (isSuccess) {
        context.push(
          AppRoutes.haroldIntakeRouteName,
          extra: HaroldIntakeQuestionsScreenParams(fromAuthFlow: false, query: query, fee: fee, userType: userType, evaluationId: evaluationId),
        );
      } else {
        context.push(AppRoutes.haroldFailedRouteName, extra: HaroldFailedScreenParams(fromAuthFlow: false, query: query));
      }
    } else {
      HaroldNavigationService().storePendingResult(isSuccess, query, fee, userType, evaluationId);
      context.push(AppRoutes.haroldSignupRouteName);
    }
  }

  static void handlePostAuthNavigation(BuildContext context) {
    final data = HaroldNavigationService().getPendingResultAndQuery();
    final pendingResult = data['result'] as String?;
    final pendingQuery = data['query'] as String?;
    final pendingFee = data['fee'] as ConsultationFee?;
    final pendingUserType = data['userType'] as String?;
    final pendingEvaluationId = data['evaluationId'] as String?;

    if (pendingResult != null) {
      if (pendingResult == 'success') {
        context.go(
          AppRoutes.haroldIntakeRouteName,
          extra: HaroldIntakeQuestionsScreenParams(
            fromAuthFlow: true,
            query: pendingQuery ?? '',
            fee: pendingFee,
            userType: pendingUserType,
            evaluationId: pendingEvaluationId,
          ),
        );
      } else {
        context.go(AppRoutes.haroldFailedRouteName, extra: HaroldFailedScreenParams(fromAuthFlow: true, query: pendingQuery));
      }
    } else {
      context.go(AppRoutes.homeRouteName);
    }
  }
}
