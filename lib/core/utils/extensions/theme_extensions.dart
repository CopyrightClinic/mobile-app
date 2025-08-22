import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get textColor => Theme.of(this).colorScheme.onSurface;
  Color get successColor => AppTheme.successColor;
  Color get errorColor => AppTheme.errorColor;
  Color get warningColor => AppTheme.warningColor;
}

extension ThemeSpacing on BuildContext {
  double get spacingSmall => AppTheme.spacingSmall;
  double get spacingMedium => AppTheme.spacingMedium;
  double get spacingLarge => AppTheme.spacingLarge;
  double get radiusSmall => AppTheme.radiusSmall;
  double get radiusMedium => AppTheme.radiusMedium;
  double get radiusLarge => AppTheme.radiusLarge;
}

extension ThemeTextStyles on BuildContext {
  TextStyle get headlineStyle => AppTheme.headlineStyle.copyWith(color: Theme.of(this).colorScheme.onSurface);
  TextStyle get titleStyle => AppTheme.titleStyle.copyWith(color: Theme.of(this).colorScheme.onSurface);
  TextStyle get bodyStyle => AppTheme.bodyStyle.copyWith(color: Theme.of(this).colorScheme.onSurface);
  TextStyle get captionStyle => AppTheme.captionStyle.copyWith(color: Theme.of(this).colorScheme.onSurface);
}
