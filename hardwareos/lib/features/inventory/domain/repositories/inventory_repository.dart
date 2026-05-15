import '../entities/product.dart';

/// Repository interface defining the contract for inventory data operations.
/// This is part of the Domain layer and defines WHAT operations are available,
/// not HOW they are implemented (that's the Data layer's responsibility).
abstract class InventoryRepository {
  /// Get all products for a tenant with optional filtering
  Future<List<Product>> getProducts({
    required String tenantId,
    String? categoryId,
    String? searchQuery,
    bool? lowStockOnly,
    int limit = 50,
    int offset = 0,
  });

  /// Get a single product by ID
  Future<Product?> getProductById({
    required String tenantId,
    required String productId,
  });

  /// Get products by category
  Future<List<Product>> getProductsByCategory({
    required String tenantId,
    required String categoryId,
  });

  /// Get low stock products
  Future<List<Product>> getLowStockProducts({
    required String tenantId,
  });

  /// Create a new product
  Future<Product> createProduct({
    required String tenantId,
    required String name,
    String? sku,
    String? barcode,
    required String categoryId,
    required String categoryName,
    required double unitPrice,
    required double costPrice,
    required String unitOfMeasure,
    required int minStockLevel,
    required int maxStockLevel,
    String? description,
  });

  /// Update an existing product
  Future<Product> updateProduct({
    required String tenantId,
    required String productId,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    double? unitPrice,
    double? costPrice,
    String? unitOfMeasure,
    int? minStockLevel,
    int? maxStockLevel,
    String? description,
    bool? isActive,
  });

  /// Delete a product (soft delete)
  Future<void> deleteProduct({
    required String tenantId,
    required String productId,
  });

  /// Update product stock
  Future<Product> updateStock({
    required String tenantId,
    required String productId,
    required int quantityChange,
    required String reason,
    required String performedBy,
    required String performedByName,
    String? referenceId,
    String? referenceType,
  });

  /// Get stock movement history for a product
  Future<List<StockMovement>> getProductMovements({
    required String tenantId,
    required String productId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  });

  /// Record a stock movement
  Future<StockMovement> recordMovement({
    required String tenantId,
    required String productId,
    required String productName,
    required String productSku,
    required MovementType movementType,
    required int quantity,
    required int stockBefore,
    required int stockAfter,
    String? referenceId,
    String? referenceType,
    String? warehouseId,
    String? warehouseName,
    String? reason,
    required String performedBy,
    required String performedByName,
  });

  /// Get inventory summary statistics
  Future<InventoryStats> getInventoryStats({
    required String tenantId,
  });

  /// Search products by barcode
  Future<Product?> getProductByBarcode({
    required String tenantId,
    required String barcode,
  });

  /// Search products by SKU
  Future<Product?> getProductBySku({
    required String tenantId,
    required String sku,
  });
}

/// Inventory statistics data class
class InventoryStats {
  final int totalProducts;
  final int totalCategories;
  final int lowStockCount;
  final int outOfStockCount;
  final int overstockedCount;
  final double totalInventoryValue;
  final DateTime lastUpdated;

  const InventoryStats({
    required this.totalProducts,
    required this.totalCategories,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.overstockedCount,
    required this.totalInventoryValue,
    required this.lastUpdated,
  });

  InventoryStats copyWith({
    int? totalProducts,
    int? totalCategories,
    int? lowStockCount,
    int? outOfStockCount,
    int? overstockedCount,
    double? totalInventoryValue,
    DateTime? lastUpdated,
  }) {
    return InventoryStats(
      totalProducts: totalProducts ?? this.totalProducts,
      totalCategories: totalCategories ?? this.totalCategories,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      overstockedCount: overstockedCount ?? this.overstockedCount,
      totalInventoryValue: totalInventoryValue ?? this.totalInventoryValue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
