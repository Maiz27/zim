import 'package:flutter/material.dart';

class ThemeConfig {
  //Colors for theme
  static Color primary = const Color(0xFF11999E);
  static Color accent = const Color(0xFF30E3CA);
  static Color secondary = const Color(0xFF406882);
  static Color accent2 = const Color(0xFF1A374D);
  static Color darkBg = const Color(0xFF222831);
  static Color lightBg = const Color(0xFFE5FAF6);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, secondary: accent, surface: darkBg),
    appBarTheme: AppBarTheme(
      elevation: 4,
      backgroundColor: primary,
      titleTextStyle: TextStyle(
        color: lightBg,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: lightBg, elevation: 2),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      circularTrackColor: darkBg.withValues(alpha: 0.1),
      color: primary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkBg,
      textStyle: TextStyle(color: lightBg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: primary,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: primary),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent, //thereby
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(primary: primary, secondary: accent, surface: lightBg),
    appBarTheme: AppBarTheme(
      elevation: 4,
      backgroundColor: primary,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: darkBg, elevation: 2),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      circularTrackColor: lightBg.withValues(alpha: 0.8),
      color: primary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: lightBg,
      textStyle: TextStyle(color: darkBg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: primary,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: primary),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent, //thereby
    ),
  );
}
