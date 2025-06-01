import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Brand)
  static const Color primary = Color(0xFF4361EE); // Vibrant blue
  static const Color primaryDark = Color(0xFF3A56E0);
  static const Color primaryLight = Color(0xFF5F7BFF);

  // input text field color

  // Secondary Colors
  static const Color secondary = Color(0xFF06D6A0); // Teal
  static const Color secondaryDark = Color.fromARGB(255, 89, 91, 90);
  static const Color secondaryLight = Color(0xFF0DFFBC);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background & Surface
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF1F3F9);
  static const Color textField = Color(0xFFF5F7FB);

  // Text & Icons
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color icon = Color(0xFF5F6368);

  // Text field
  static const Color textFieldPrimary = Color(0xFF212121);
  static const Color textFieldSecondary = Color(0xFF757575);
  static const Color textFieldDisabled = Color(0xFF9E9E9E);
  static const Color textFieldIcon = Color(0xFF5F6368);

  // Borders & Dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [success, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
