import 'package:flutter/material.dart';
import "./color_pelette.dart";

class AppTextTheme {
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    ),
  );

  static TextTheme get darkTextTheme => lightTextTheme.copyWith(
    displayLarge: lightTextTheme.displayLarge!.copyWith(color: Colors.white),
    displayMedium: lightTextTheme.displayMedium!.copyWith(color: Colors.white),
    displaySmall: lightTextTheme.displaySmall!.copyWith(color: Colors.white),
    headlineMedium: lightTextTheme.headlineMedium!.copyWith(
      color: Colors.white,
    ),
    headlineSmall: lightTextTheme.headlineSmall!.copyWith(color: Colors.white),
    titleLarge: lightTextTheme.titleLarge!.copyWith(color: Colors.white),
    titleMedium: lightTextTheme.titleMedium!.copyWith(color: Colors.white),
    titleSmall: lightTextTheme.titleSmall!.copyWith(color: Colors.white70),
    bodyLarge: lightTextTheme.bodyLarge!.copyWith(color: Colors.white70),
    bodyMedium: lightTextTheme.bodyMedium!.copyWith(color: Colors.white70),
    bodySmall: lightTextTheme.bodySmall!.copyWith(color: Colors.white60),
    labelLarge: lightTextTheme.labelLarge!.copyWith(color: Colors.white),
    labelMedium: lightTextTheme.labelMedium!.copyWith(color: Colors.white),
  );
}
