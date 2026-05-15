import '../entities/product.dart';
import '../repositories/inventory_repository.dart';

/// Use case for retrieving a list of products.
/// This encapsulates the business logic for fetching products with filtering options.
class GetProducts {
  final InventoryRepository repository;

  GetProducts(this.repository);

  /// Execute the use case
  Future<List<Product>> call({
    required String tenantId,
    String? categoryId,
    String? searchQuery,
    bool? lowStockOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    return await repository.getProducts(
      tenantId: tenantId,
      categoryId: categoryId,
      searchQuery: searchQuery,
      lowStockOnly: lowStockOnly,
      limit: limit,
      offset: offset,
    );
  }
}
