import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Utility class for showing standardized SnackBars throughout the app
class SnackBarUtils {
  SnackBarUtils._();

  /// Shows a success SnackBar with green background
  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, duration: duration));
  }

  /// Shows an error SnackBar with red background and dismiss action
  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 4), bool showDismissAction = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
        action:
            showDismissAction
                ? SnackBarAction(
                  label: tr(AppStrings.dismiss),
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                )
                : null,
      ),
    );
  }

  /// Shows an info SnackBar with primary color background
  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).primaryColor, duration: duration));
  }

  /// Shows a warning SnackBar with orange background
  static void showWarning(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.orange, duration: duration));
  }

  /// Shows a custom SnackBar with specified parameters
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: backgroundColor, duration: duration, action: action));
  }

  /// Hides the current SnackBar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
