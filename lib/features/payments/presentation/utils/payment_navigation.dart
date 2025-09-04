import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';

class PaymentNavigation {
  /// Navigate to Add Payment Method screen
  static void navigateToAddPaymentMethod(BuildContext context) {
    context.pushNamed(AppRoutes.addPaymentMethodRouteName);
  }

  /// Navigate to Add Payment Method screen and wait for result
  static Future<bool?> navigateToAddPaymentMethodAndWait(BuildContext context) async {
    final result = await context.pushNamed<bool>(AppRoutes.addPaymentMethodRouteName);
    return result;
  }
}
