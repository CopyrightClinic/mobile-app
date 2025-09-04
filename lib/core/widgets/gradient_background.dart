import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBackground({Key? key, required this.child, this.gradient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            (isDark
                ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.bgDark, AppTheme.bgDark2, AppTheme.bgDark],
                  stops: const [0.0, 0.5, 1.0],
                )
                : AppTheme.customBackgroundGradient),
      ),
      child: child,
    );
  }
}
