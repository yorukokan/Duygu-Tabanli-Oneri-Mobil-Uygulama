import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFEC5B13);
  static const bg = Color(0xFFF8F6F6);
  static const bgAlt = Color(0xFFF8F9FA);
  static const card = Colors.white;
  static const creamCard = Color(0xFFFFFDF9);

  static const textDark = Color(0xFF0F172A);
  static const textMain = Color(0xFF334155);
  static const textMuted = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);

  static const border = Color(0xFFF1F5F9);
  static const softBorder = Color(0xFFF7D9C7);
  static const divider = Color(0xFFE2E8F0);
}

class AppShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bg,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}