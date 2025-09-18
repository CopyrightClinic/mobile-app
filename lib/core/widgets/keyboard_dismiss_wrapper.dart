import 'package:flutter/material.dart';

/// A wrapper widget that dismisses the keyboard when the user taps outside of it.
///
/// This widget wraps the entire app or screen content and provides global
/// keyboard dismissal functionality. When a user taps anywhere outside of
/// text input fields, the keyboard will automatically close.
///
/// Usage:
/// ```dart
/// KeyboardDismissWrapper(
///   child: YourAppContent(),
/// )
/// ```
class KeyboardDismissWrapper extends StatelessWidget {
  /// The child widget to wrap with keyboard dismissal functionality
  final Widget child;

  /// Whether to dismiss keyboard on tap. Defaults to true.
  final bool dismissOnTap;

  const KeyboardDismissWrapper({super.key, required this.child, this.dismissOnTap = true});

  @override
  Widget build(BuildContext context) {
    if (!dismissOnTap) {
      return child;
    }

    return GestureDetector(
      onTap: () {
        // Remove focus from any currently focused widget
        // This will cause the keyboard to dismiss
        FocusScope.of(context).unfocus();
      },
      // Ensure the gesture detector doesn't interfere with child interactions
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
