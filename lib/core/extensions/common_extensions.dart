import 'package:flutter/foundation.dart';

/// String extensions for common operations
extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isEmptyOrNull => trim().isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncate string with ellipsis
  String truncate(int length) {
    if (length <= 0) return '';
    if (length >= length) return this;
    return '${substring(0, length)}...';
  }

  /// Remove all whitespace
  String removeWhitespace() => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is a valid Philippine mobile number
  bool get isValidPhilippineMobile {
    return RegExp(r'^(09|\+639)\d{9}$').hasMatch(this);
  }

  /// Format as currency (PHP)
  String toCurrency() {
    final number = double.tryParse(this);
    if (number == null) return this;
    return '₱${number.toStringAsFixed(2)}';
  }
}

/// Nullable string extensions
extension NullableStringExtensions on String? {
  /// Check if nullable string is null or empty
  bool get isNullOrEmpty => this?.trim().isEmpty ?? true;

  /// Check if nullable string is not null and not empty
  bool get isNotNullOrEmpty => this?.trim().isNotEmpty ?? true;

  /// Or empty string if null
  String get orEmpty => this ?? '';
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isEmptyOrNull => isEmpty;

  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Safe element at index
  T? elementAtSafe(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

/// Map extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Check if map is null or empty
  bool get isEmptyOrNull => isEmpty;

  /// Get value or default
  V valueOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Format to PHP date format
  String toPhpFormat() {
    return toString().split(' ')[0];
  }

  /// Format to readable date
  String toReadableDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Format to time only
  String toTimeOnly() {
    final hour = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }
}

/// Nullable DateTime extensions
extension NullableDateTimeExtensions on DateTime? {
  /// Or now if null
  DateTime get orNow => this ?? DateTime.now();
}

/// Double extensions
extension DoubleExtensions on double {
  /// Round to 2 decimal places
  double roundTo2Decimals() {
    return double.parse(toStringAsFixed(2));
  }

  /// Format as currency
  String toCurrency() {
    return '₱${toStringAsFixed(2)}';
  }

  /// Format with commas
  String withCommas() {
    return toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// Int extensions
extension IntExtensions on int {
  /// Format with commas
  String withCommas() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format as currency
  String toCurrency() {
    return '₱${toString()}.00';
  }

  /// Convert to days duration
  Duration get days => Duration(days: this);

  /// Convert to hours duration
  Duration get hours => Duration(hours: this);

  /// Convert to minutes duration
  Duration get minutes => Duration(minutes: this);
}

/// Boolean extensions
extension BoolExtensions on bool {
  /// Toggle boolean
  bool toggle() => !this;

  /// To int (1 or 0)
  int toInt() => this ? 1 : 0;
}
