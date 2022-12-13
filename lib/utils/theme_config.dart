import 'package:flutter/material.dart';

class ThemeConfig {
  //Colors for theme
  // static Color lightPrimary = Color(0xfff3f4f9);
  // static Color darkPrimary = Color(0xff1f1f1f);
  // static Color lightAccent = Color(0xff597ef7);
  // static Color darkAccent = Color(0xff597ef7);
  // static Color lightBG = Color(0xfff3f4f9);
  // static Color darkBG = Color(0xff121212);
  // static Color backgroundSmokeWhite = Color(0xffB0C6D0).withOpacity(0.1);

  static Color primary = const Color(0xFF11999E);
  static Color accent = const Color(0xFF30E3CA);
  static Color secondary = const Color(0xFF406882);
  static Color accent2 = const Color(0xFF1A374D);
  static Color darkBg = const Color(0xFF222831);
  static Color lightBg = const Color(0xFFE5FAF6);

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBg,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBg,
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: primary,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
    ),
    textTheme: TextTheme(
      //color for icons (icon fonts) base on theme
      headline6: TextStyle(
        color: darkBg,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBg,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBg,
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: primary,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      //color for icons (icon fonts) base on theme
      headline6: TextStyle(
        color: lightBg,
      ),
    ),
  );
}
