import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Use case for getting inventory statistics.
class GetInventoryStats {
  final InventoryRepository repository;

  GetInventoryStats(this.repository);

  /// Execute the use case
  Future<InventoryStats> call({required String tenantId}) async {
    return await repository.getInventoryStats(tenantId: tenantId);
  }
}
