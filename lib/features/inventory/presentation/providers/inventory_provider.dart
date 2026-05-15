import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product_stock.dart';
import '../../domain/usecases/get_inventory_stats.dart';

/// Provider for the InventoryRepository implementation using Supabase.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final supabase = Supabase.instance.client;
  return InventoryRepositoryImpl(supabase: supabase);
});

/// Provider for GetProducts use case.
final getProductsProvider = Provider<GetProducts>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetProducts(repository);
});

/// Provider for CreateProduct use case.
final createProductProvider = Provider<CreateProduct>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return CreateProduct(repository);
});

/// Provider for UpdateProductStock use case.
final updateProductStockProvider = Provider<UpdateProductStock>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return UpdateProductStock(repository);
});

/// Provider for GetInventoryStats use case.
final getInventoryStatsProvider = Provider<GetInventoryStats>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetInventoryStats(repository);
});

/// State class for inventory list.
class InventoryListState {
  final bool isLoading;
  final List<Product> products;
  final String? error;
  final bool hasMore;

  const InventoryListState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.hasMore = true,
  });

  InventoryListState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
    bool? hasMore,
  }) {
    return InventoryListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Notifier provider for managing inventory list state.
final inventoryListNotifierProvider = 
    NotifierProvider<InventoryListNotifier, InventoryListState>(() {
  return InventoryListNotifier();
});

/// Notifier for inventory list operations.
class InventoryListNotifier extends Notifier<InventoryListState> {
  @override
  InventoryListState build() {
    return const InventoryListState();
  }

  /// Load products with optional filters
  Future<void> loadProducts({
    required String tenantId,
    String? categoryId,
    String? searchQuery,
    bool? lowStockOnly,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getProducts = ref.read(getProductsProvider);
      final products = await getProducts(
        tenantId: tenantId,
        categoryId: categoryId,
        searchQuery: searchQuery,
        lowStockOnly: lowStockOnly,
      );

      state = state.copyWith(
        isLoading: false,
        products: products,
        hasMore: products.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh the product list
  Future<void> refresh({required String tenantId}) async {
    await loadProducts(tenantId: tenantId);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for inventory statistics state.
final inventoryStatsProvider = 
    FutureProvider.autoDispose.family<InventoryStats, String>((ref, tenantId) async {
  final getStats = ref.read(getInventoryStatsProvider);
  return await getStats(tenantId: tenantId);
});
