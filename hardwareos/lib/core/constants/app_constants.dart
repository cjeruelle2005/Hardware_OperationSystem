import 'package:flutter/material.dart';

/// App-level constants used throughout HardwareOS
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'HardwareOS';
  static const String appVersion = '1.0.0';
  
  // Brand Colors
  static const int primaryColorValue = 0xFFFF6B35; // Industrial Orange
  static const int secondaryColorValue = 0xFF2D3748; // Dark Gray
  static const int accentColorValue = 0xFFED8936; // Lighter Orange
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double inputRadius = 6.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int largePageSize = 50;
  
  // Cache & Sync
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration syncInterval = Duration(seconds: 30);
  
  // Form Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png', 'image/jpg'];
  
  // Tenant Defaults
  static const String defaultCurrency = 'PHP';
  static const String defaultTimezone = 'Asia/Manila';
  static const String defaultDateFormat = 'MMM dd, yyyy';
  static const String defaultDateTimeFormat = 'MMM dd, yyyy hh:mm a';
}
