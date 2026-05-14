// App-wide constants for HardwareOS

class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'HardwareOS';
  static const String appVersion = '1.0.0';
  
  // Tenant Roles
  static const String roleOwner = 'owner';
  static const String roleManager = 'manager';
  static const String roleSales = 'sales';
  static const String roleWarehouse = 'warehouse';
  static const String roleViewer = 'viewer';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Session Timeout (milliseconds)
  static const int sessionTimeoutMs = 3600000; // 1 hour
  
  // Sync Configuration
  static const int syncBatchSize = 50;
  static const Duration syncInterval = Duration(minutes: 5);
  
  // Currency
  static const String defaultCurrency = 'PHP';
  static const String currencySymbol = '₱';
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
}
