import 'package:supabase_flutter/supabase_flutter.dart';
import '../../entities/product.dart';
import '../../entities/inventory_category.dart';
import '../../entities/stock_movement.dart';
import '../../../../core/errors/exceptions.dart';

/// Remote data source for inventory operations using Supabase.
class InventoryRemoteDataSource {
  final SupabaseClient supabase;

  InventoryRemoteDataSource({required this.supabase});

  /// Fetch products from remote server
  Future<List<Product>> getProducts({
    required String tenantId,
    String? categoryId,
    String? searchQuery,
    bool? lowStockOnly,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = supabase
          .from('products')
          .select('''
            *,
            inventory_categories(name)
          ''')
          .eq('tenant_id', tenantId)
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,sku.ilike.%$searchQuery%');
      }

      final response = await query.range(offset, offset + limit - 1);
      return (response as List).map(_productFromJson).toList();
    } on PostgrestException catch (e) {
      throw DataException('Failed to fetch products: ${e.message}');
    } catch (e) {
      throw DataException('Unexpected error fetching products: $e');
    }
  }

  /// Convert JSON map to Product entity
  Product _productFromJson(Map<String, dynamic> json) {
    final category = json['inventory_categories'] as Map<String, dynamic>?;
    
    return Product(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      categoryId: json['category_id'] as String,
      categoryName: category?['name'] as String? ?? 'Unknown',
      unitPrice: (json['unit_price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      unitOfMeasure: json['unit_of_measure'] as String,
      currentStock: json['current_stock'] as int,
      minStockLevel: json['min_stock_level'] as int,
      maxStockLevel: json['max_stock_level'] as int,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert JSON map to StockMovement entity
  StockMovement _stockMovementFromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String,
      movementType: MovementType.values.firstWhere(
        (e) => e.name == json['movement_type'],
        orElse: () => MovementType.adjustmentIn,
      ),
      quantity: json['quantity'] as int,
      stockBefore: json['stock_before'] as int,
      stockAfter: json['stock_after'] as int,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      warehouseId: json['warehouse_id'] as String?,
      warehouseName: json['warehouse_name'] as String?,
      reason: json['reason'] as String?,
      performedBy: json['performed_by'] as String,
      performedByName: json['performed_by_name'] as String,
      movementDate: DateTime.parse(json['movement_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
