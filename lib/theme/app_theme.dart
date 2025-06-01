import 'package:flutter/material.dart';
import './color_pelette.dart';
import './text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: AppTextTheme.lightTextTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.icon),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: Color(0xFF1E1E1E),
        error: AppColors.error,
      ),
      textTheme: AppTextTheme.darkTextTheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white70),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.secondaryDark,

        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
        space: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
