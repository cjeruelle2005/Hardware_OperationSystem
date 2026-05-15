import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Use case for creating a new product.
/// Encapsulates business rules for product creation.
class CreateProduct {
  final InventoryRepository repository;

  CreateProduct(this.repository);

  /// Execute the use case
  Future<Product> call({
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
  }) async {
    // Business rule: Validate prices
    if (unitPrice < 0) {
      throw ArgumentError('Unit price cannot be negative');
    }
    if (costPrice < 0) {
      throw ArgumentError('Cost price cannot be negative');
    }

    // Business rule: Validate stock levels
    if (minStockLevel < 0) {
      throw ArgumentError('Minimum stock level cannot be negative');
    }
    if (maxStockLevel < minStockLevel) {
      throw ArgumentError('Maximum stock level must be >= minimum stock level');
    }

    // Business rule: Validate name
    if (name.trim().isEmpty) {
      throw ArgumentError('Product name is required');
    }

    return await repository.createProduct(
      tenantId: tenantId,
      name: name,
      sku: sku,
      barcode: barcode,
      categoryId: categoryId,
      categoryName: categoryName,
      unitPrice: unitPrice,
      costPrice: costPrice,
      unitOfMeasure: unitOfMeasure,
      minStockLevel: minStockLevel,
      maxStockLevel: maxStockLevel,
      description: description,
    );
  }
}
