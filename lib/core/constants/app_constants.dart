/// App-wide constants for HardwareOS
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'HardwareOS';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Operational Infrastructure';

  // API & Network
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int cacheDurationMinutes = 5;
  static const int longCacheDurationHours = 24;

  // File Upload
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // Database
  static const String databaseName = 'hardwareos_local.db';
  
  // Sync
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelaySeconds = 5;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double cardElevation = 0;
  
  // Animation
  static const int shortAnimationDuration = 200;
  static const int standardAnimationDuration = 300;
}
