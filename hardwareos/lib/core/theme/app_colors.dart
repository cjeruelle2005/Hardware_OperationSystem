// Theme - Industrial color palette for HardwareOS

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Industrial Orange)
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryOrangeLight = Color(0xFFFF8C61);
  static const Color primaryOrangeDark = Color(0xFFE55A2B);
  
  // Secondary Colors (Dark Gray)
  static const Color primaryGray = Color(0xFF2C2C2C);
  static const Color primaryGrayLight = Color(0xFF3D3D3D);
  static const Color primaryGrayDark = Color(0xFF1A1A1A);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // Background Colors
  static const Color backgroundPrimary = gray50;
  static const Color backgroundSecondary = white;
  static const Color backgroundDark = primaryGray;
  
  // Surface Colors
  static const Color surface = white;
  static const Color surfaceVariant = gray100;
  
  // Text Colors
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray500;
  static const Color textOnDark = white;
  static const Color textOnPrimary = white;
  
  // Border Colors
  static const Color border = gray200;
  static const Color borderStrong = gray300;
  
  // Status Colors for Inventory
  static const Color inStock = success;
  static const Color lowStock = warning;
  static const Color outOfStock = error;
  static const Color incoming = info;
}
