import 'package:flutter/material.dart';

class KeyboardDismissWrapper extends StatelessWidget {
  final Widget child;

  final bool dismissOnTap;

  const KeyboardDismissWrapper({super.key, required this.child, this.dismissOnTap = true});

  @override
  Widget build(BuildContext context) {
    if (!dismissOnTap) {
      return child;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
