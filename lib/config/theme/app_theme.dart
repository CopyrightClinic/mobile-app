import 'package:flutter/material.dart';

class AppTheme {
  // Figma Color Palette
  static const Color primary = Color(0xFF6882F7);
  static const Color textPrimary = Color(0xFF191919);
  static const Color textBody = Color(0xFF404145);
  static const Color textBodyLight = Color(0xFF4B5563);
  static const Color border = Color(0xFFE4E7EB);
  static const Color placeholder = Color(0xFF9BA3AF);
  static const Color green = Color(0xFF32BA78);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFEB5756);
  static const Color secondary = Color(0xFF8E9EC7);
  static const Color secondary2 = Color(0xFFECEFF3);
  static const Color greyLight = Color(0xFFF4F7F9);
  static const Color bgDark = Color(0xFF16181D);
  static const Color gradientBgDark = Color(0xFF38393A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF7F909F);
  static const Color filledBgDark = Color(0xFF1F232B);
  static const Color darkSecondary = Color(0xFFBBEBFF);
  static const Color bgDark2 = Color(0xFF202427);
  static const Color secondary2Alt = Color(0xFFE8EBEC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color buttonDiabled = Color(0xFF3E414A);

  // Custom Gradient Background Colors
  static const Color gradientBgDark1 = Color(0xFF6882F7); // #6882F7 with 36% opacity
  static const Color gradientBgDark2 = Color(0xFF1E6892); // #1E6892 with 5% opacity
  static const Color gradientBgDark3 = Color(0xFF16181E); // #16181E with 0% opacity

  // Custom Gradient Background
  static LinearGradient customBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x4C6882F7), // #6882F7 with 36% opacity (0x5C = 36%)
      Color(0x0D1E6892), // #1E6892 with 5% opacity (0x0D = 5%)
      Color(0x0016181E), // #16181E with 0% opacity (0x00 = 0%)
    ],
    stops: [0.05, 0.25, 1.0],
  );

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;

  static const String fontFamily = 'Urbanist';

  static const TextStyle headlineStyle = TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, fontFamily: fontFamily);

  static const TextStyle titleStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, fontFamily: fontFamily);

  static const TextStyle bodyStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, fontFamily: fontFamily);

  static const TextStyle captionStyle = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, fontFamily: fontFamily);

  ThemeData get light => _buildLightTheme();
  ThemeData get dark => _buildDarkTheme();

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      primaryColor: primary,
      scaffoldBackgroundColor: greyLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: textPrimary,
        error: red,
        onError: Colors.white,
        background: greyLight,
        onBackground: textPrimary,
        outline: border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18.0, fontWeight: FontWeight.w600, fontFamily: fontFamily),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: textBodyLight,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        indicatorColor: primary,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primary, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: placeholder,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall)),
          textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(primary),
          shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall))),
          textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(primary),
          shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall))),
          side: WidgetStateProperty.all<BorderSide>(const BorderSide(color: primary)),
          textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
        ),
      ),
      cardTheme: CardTheme(color: Colors.white, elevation: 2.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textBodyLight,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        iconColor: placeholder,
        hintStyle: const TextStyle(color: placeholder, fontFamily: fontFamily),
        prefixIconColor: placeholder,
        suffixIconColor: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: primary, width: 2.0)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: red)),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: red, width: 2.0),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return placeholder;
        }),
      ),
      textTheme: const TextTheme(
        headlineMedium: headlineStyle,
        titleLarge: titleStyle,
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily),
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      primaryColor: primary,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: filledBgDark,
        onSurface: darkTextPrimary,
        error: red,
        onError: Colors.white,
        background: bgDark,
        onBackground: darkTextPrimary,
        outline: gradientBgDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 18.0, fontWeight: FontWeight.w600, fontFamily: fontFamily),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: darkTextSecondary,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        indicatorColor: primary,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primary, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: darkTextSecondary,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall)),
          textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(primary),
          shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall))),
          textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(primary),
          shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall))),
          side: WidgetStateProperty.all<BorderSide>(const BorderSide(color: primary)),
          textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
        ),
      ),
      cardTheme: CardTheme(color: filledBgDark, elevation: 2.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: filledBgDark,
        selectedItemColor: primary,
        unselectedItemColor: darkTextSecondary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        iconColor: darkTextSecondary,
        hintStyle: const TextStyle(color: darkTextSecondary, fontFamily: fontFamily),
        prefixIconColor: darkTextSecondary,
        suffixIconColor: darkTextSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: gradientBgDark)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: gradientBgDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: primary, width: 2.0)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSmall), borderSide: const BorderSide(color: red)),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: red, width: 2.0),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: gradientBgDark, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return darkTextSecondary;
        }),
      ),
      textTheme: const TextTheme(
        headlineMedium: headlineStyle,
        titleLarge: titleStyle,
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: fontFamily),
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
      ),
    );
  }
}
