import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF101B35);
  static const navyLight = Color(0xFF1C2B4D);
  static const orange = Color(0xFFF28C28);
  static const ivory = Color(0xFFFFF8ED);
  static const green = Color(0xFF2EB67D);
  static const muted = Color(0xFF8E9AB3);

  static ThemeData get data => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
          surface: navyLight,
        ),
        fontFamily: 'sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: ivory,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ivory.withValues(alpha: 0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: orange, width: 1.5),
          ),
          hintStyle: const TextStyle(color: muted),
        ),
      );
}
