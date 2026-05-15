import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Use case for updating product stock levels.
/// Encapsulates business rules for stock adjustments.
class UpdateProductStock {
  final InventoryRepository repository;

  UpdateProductStock(this.repository);

  /// Execute the use case
  Future<Product> call({
    required String tenantId,
    required String productId,
    required int quantityChange,
    required String reason,
    required String performedBy,
    required String performedByName,
    String? referenceId,
    String? referenceType,
  }) async {
    // Business rule: Validate quantity change
    if (quantityChange == 0) {
      throw ArgumentError('Quantity change cannot be zero');
    }

    // Business rule: Validate reason
    if (reason.trim().isEmpty) {
      throw ArgumentError('Reason for stock change is required');
    }

    // Business rule: Validate user
    if (performedBy.trim().isEmpty) {
      throw ArgumentError('User performing the action is required');
    }

    return await repository.updateStock(
      tenantId: tenantId,
      productId: productId,
      quantityChange: quantityChange,
      reason: reason,
      performedBy: performedBy,
      performedByName: performedByName,
      referenceId: referenceId,
      referenceType: referenceType,
    );
  }
}
