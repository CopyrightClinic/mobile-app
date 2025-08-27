import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get textColor => Theme.of(this).colorScheme.onSurface;

  // AppTheme color extensions
  Color get primary => AppTheme.primary;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textBody => AppTheme.textBody;
  Color get textBodyLight => AppTheme.textBodyLight;
  Color get border => AppTheme.border;
  Color get placeholder => AppTheme.placeholder;
  Color get green => AppTheme.green;
  Color get orange => AppTheme.orange;
  Color get red => AppTheme.red;
  Color get secondary => AppTheme.secondary;
  Color get secondary2 => AppTheme.secondary2;
  Color get greyLight => AppTheme.greyLight;
  Color get bgDark => AppTheme.bgDark;
  Color get gradientBgDark => AppTheme.gradientBgDark;
  Color get darkTextPrimary => AppTheme.darkTextPrimary;
  Color get darkTextSecondary => AppTheme.darkTextSecondary;
  Color get filledBgDark => AppTheme.filledBgDark;
  Color get darkSecondary => AppTheme.darkSecondary;
  Color get bgDark2 => AppTheme.bgDark2;
  Color get secondary2Alt => AppTheme.secondary2Alt;
  Color get buttonDiabled => AppTheme.buttonDiabled;
  Color get white => AppTheme.white;
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
