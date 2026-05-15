import 'package:flutter/material.dart';

/// Color palette for HardwareOS - Industrial, professional theme
class AppColors {
  AppColors._();

  // Primary Colors (Industrial Orange)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryOpaque = Color(0xFFFF6B35);

  // Secondary Colors (Dark Gray)
  static const Color secondary = Color(0xFF2D3748);
  static const Color secondaryLight = Color(0xFF4A5568);
  static const Color secondaryDark = Color(0xFF1A202C);

  // Background Colors
  static const Color background = Color(0xFFF7FAFC);
  static const Color backgroundDark = Color(0xFF1A202C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D3748);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);

  // Border & Divider Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);
  static const Color borderDark = Color(0xFF4A5568);

  // Input Colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFocus = Color(0xFFFF6B35);
  static const Color inputError = Color(0xFFF56565);

  // Chart & Analytics Colors
  static const List<Color> chartColors = [
    Color(0xFFFF6B35), // Primary Orange
    Color(0xFF4299E1), // Blue
    Color(0xFF48BB78), // Green
    Color(0xFFED8936), // Light Orange
    Color(0xFF9F7AEA), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF38B2AC), // Teal
    Color(0xFFF56565), // Red
  ];

  // Warehouse & Industrial Colors
  static const Color warehouse = Color(0xFF4A5568);
  static const Color inventory = Color(0xFF4299E1);
  static const Color procurement = Color(0xFF48BB78);
  static const Color sales = Color(0xFFED8936);
}
