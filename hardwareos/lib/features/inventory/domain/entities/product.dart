import 'package:equatable/equatable.dart';

/// Domain entity representing a Product in the Inventory system.
/// This is the pure business object without any data-layer dependencies.
class Product extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? sku;
  final String? barcode;
  final String categoryId;
  final String categoryName;
  final double unitPrice;
  final double costPrice;
  final String unitOfMeasure;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.tenantId,
    required this.name,
    this.sku,
    this.barcode,
    required this.categoryId,
    required this.categoryName,
    required this.unitPrice,
    required this.costPrice,
    required this.unitOfMeasure,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if stock is below minimum level
  bool get isLowStock => currentStock < minStockLevel;

  /// Check if stock is above maximum level
  bool get isOverStocked => currentStock > maxStockLevel;

  /// Calculate stock status
  StockStatus get stockStatus {
    if (isLowStock) return StockStatus.low;
    if (isOverStocked) return StockStatus.overstocked;
    return StockStatus.normal;
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        sku,
        barcode,
        categoryId,
        categoryName,
        unitPrice,
        costPrice,
        unitOfMeasure,
        currentStock,
        minStockLevel,
        maxStockLevel,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Create a copy of this product with updated fields
  Product copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    double? unitPrice,
    double? costPrice,
    String? unitOfMeasure,
    int? currentStock,
    int? minStockLevel,
    int? maxStockLevel,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Stock status enumeration
enum StockStatus {
  low,
  normal,
  overstocked,
}

/// Extension to get display string for stock status
extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.low:
        return 'Low Stock';
      case StockStatus.normal:
        return 'Normal';
      case StockStatus.overstocked:
        return 'Overstocked';
    }
  }

  String get colorCode {
    switch (this) {
      case StockStatus.low:
        return 'FF4444'; // Red
      case StockStatus.normal:
        return '4CAF50'; // Green
      case StockStatus.overstocked:
        return 'FF9800'; // Orange
    }
  }
}
