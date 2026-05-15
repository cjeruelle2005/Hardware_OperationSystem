import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_category.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Implementation of InventoryRepository using Supabase as data source.
class InventoryRepositoryImpl implements InventoryRepository {
  final SupabaseClient supabase;

  InventoryRepositoryImpl({required this.supabase});

  @override
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

      if (lowStockOnly == true) {
        query = query.lt('current_stock', minStockLevel);
      }

      final response = await query.range(offset, offset + limit - 1);

      return (response as List).map((item) => _productFromJson(item)).toList();
    } on PostgrestException catch (e) {
      throw DataException('Failed to fetch products: ${e.message}');
    } catch (e) {
      throw DataException('Unexpected error fetching products: $e');
    }
  }

  @override
  Future<Product?> getProductById({
    required String tenantId,
    required String productId,
  }) async {
    try {
      final response = await supabase
          .from('products')
          .select('''
            *,
            inventory_categories(name)
          ''')
          .eq('tenant_id', tenantId)
          .eq('id', productId)
          .single();

      if (response == null) return null;
      return _productFromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return null; // Not found
      throw DataException('Failed to fetch product: ${e.message}');
    } catch (e) {
      throw DataException('Unexpected error fetching product: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required String tenantId,
    required String categoryId,
  }) async {
    return getProducts(tenantId: tenantId, categoryId: categoryId);
  }

  @override
  Future<List<Product>> getLowStockProducts({
    required String tenantId,
  }) async {
    return getProducts(tenantId: tenantId, lowStockOnly: true);
  }

  @override
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
  }) async {
    try {
      final response = await supabase.from('products').insert({
        'tenant_id': tenantId,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'category_id': categoryId,
        'unit_price': unitPrice,
        'cost_price': costPrice,
        'unit_of_measure': unitOfMeasure,
        'current_stock': 0,
        'min_stock_level': minStockLevel,
        'max_stock_level': maxStockLevel,
        'description': description,
        'is_active': true,
      }).select('''
        *,
        inventory_categories(name)
      ''').single();

      return _productFromJson(response);
    } on PostgrestException catch (e) {
      throw DataException('Failed to create product: ${e.message}');
    } catch (e) {
      throw DataException('Unexpected error creating product: $e');
    }
  }

  @override
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
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (name != null) updates['name'] = name;
      if (sku != null) updates['sku'] = sku;
      if (barcode != null) updates['barcode'] = barcode;
      if (categoryId != null) updates['category_id'] = categoryId;
      if (unitPrice != null) updates['unit_price'] = unitPrice;
      if (costPrice != null) updates['cost_price'] = costPrice;
      if (unitOfMeasure != null) updates['unit_of_measure'] = unitOfMeasure;
      if (minStockLevel != null) updates['min_stock_level'] = minStockLevel;
      if (maxStockLevel != null) updates['max_stock_level'] = maxStockLevel;
      if (description != null) updates['description'] = description;
      if (isActive != null) updates['is_active'] = isActive;

      final response = await supabase
          .from('products')
          .update(updates)
          .eq('id', productId)
          .eq('tenant_id', tenantId)
          .select('''
            *,
            inventory_categories(name)
          ''')
          .single();

      return _productFromJson(response);
    } on PostgrestException catch (e) {
      throw DataException('Failed to update product: ${e.message}');
    } catch (e) {
      throw DataException('Unexpected error updating product: $e');
    }
  }

  @override
  Future<void> deleteProduct({
    required String tenantId,
    required String productId,
  }) async {
    try {
      // Soft delete - just mark as inactive
      await supabase
          .from('products')
          .update({'is_active': false})
          .eq('id', productId)
          .eq('tenant_id', tenantId);
    } on PostgrestException catch (e) {
      throw DataException('Failed to delete product: ${e.message}');
    } catch (e) {
      throw DataException('Unexpected error deleting product: $e');
    }
  }

  @override
  Future<Product> updateStock({
    required String tenantId,
    required String productId,
    required int quantityChange,
    required String reason,
    required String performedBy,
    required String performedByName,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      // Get current product to calculate new stock
      final product = await getProductById(tenantId: tenantId, productId: productId);
      if (product == null) {
        throw DataException('Product not found');
      }

      final newStock = product.currentStock + quantityChange;
      if (newStock < 0) {
        throw DataException('Insufficient stock');
      }

      // Update stock
      final updatedProduct = await updateProduct(
        tenantId: tenantId,
        productId: productId,
      );

      // Apply stock update directly via RPC or raw query
      final response = await supabase.rpc('update_product_stock', params: {
        'p_product_id': productId,
        'p_quantity_change': quantityChange,
        'p_tenant_id': tenantId,
      });

      return _productFromJson(response);
    } catch (e) {
      throw DataException('Failed to update stock: $e');
    }
  }

  @override
  Future<List<StockMovement>> getProductMovements({
    required String tenantId,
    required String productId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      var query = supabase
          .from('stock_movements')
          .select()
          .eq('tenant_id', tenantId)
          .eq('product_id', productId)
          .order('movement_date', ascending: false)
          .limit(limit);

      if (fromDate != null) {
        query = query.gte('movement_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('movement_date', toDate.toIso8601String());
      }

      final response = await query;
      return (response as List).map((item) => _stockMovementFromJson(item)).toList();
    } catch (e) {
      throw DataException('Failed to fetch stock movements: $e');
    }
  }

  @override
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
  }) async {
    try {
      final response = await supabase.from('stock_movements').insert({
        'tenant_id': tenantId,
        'product_id': productId,
        'product_name': productName,
        'product_sku': productSku,
        'movement_type': movementType.name,
        'quantity': quantity,
        'stock_before': stockBefore,
        'stock_after': stockAfter,
        'reference_id': referenceId,
        'reference_type': referenceType,
        'warehouse_id': warehouseId,
        'warehouse_name': warehouseName,
        'reason': reason,
        'performed_by': performedBy,
        'performed_by_name': performedByName,
        'movement_date': DateTime.now().toIso8601String(),
      }).select().single();

      return _stockMovementFromJson(response);
    } catch (e) {
      throw DataException('Failed to record stock movement: $e');
    }
  }

  @override
  Future<InventoryStats> getInventoryStats({
    required String tenantId,
  }) async {
    try {
      // Get total products
      final productCount = await supabase
          .from('products')
          .count()
          .eq('tenant_id', tenantId)
          .eq('is_active', true);

      // Get category count
      final categoryCount = await supabase
          .from('inventory_categories')
          .count()
          .eq('tenant_id', tenantId)
          .eq('is_active', true);

      // Get low stock count
      final lowStockResponse = await supabase
          .from('products')
          .select('id')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .lt('current_stock', refColumn: 'min_stock_level');

      final lowStockCount = (lowStockResponse as List).length;

      // Get out of stock count
      final outOfStockResponse = await supabase
          .from('products')
          .select('id')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .eq('current_stock', 0);

      final outOfStockCount = (outOfStockResponse as List).length;

      // Calculate total inventory value
      final productsResponse = await supabase
          .from('products')
          .select('current_stock,cost_price')
          .eq('tenant_id', tenantId)
          .eq('is_active', true);

      double totalValue = 0;
      for (var product in productsResponse as List) {
        totalValue += (product['current_stock'] as int) * 
                      (product['cost_price'] as num).toDouble();
      }

      return InventoryStats(
        totalProducts: productCount as int,
        totalCategories: categoryCount as int,
        lowStockCount: lowStockCount,
        outOfStockCount: outOfStockCount,
        overstockedCount: 0, // TODO: Implement
        totalInventoryValue: totalValue,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw DataException('Failed to fetch inventory stats: $e');
    }
  }

  @override
  Future<Product?> getProductByBarcode({
    required String tenantId,
    required String barcode,
  }) async {
    try {
      final response = await supabase
          .from('products')
          .select('''
            *,
            inventory_categories(name)
          ''')
          .eq('tenant_id', tenantId)
          .eq('barcode', barcode)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return _productFromJson(response);
    } catch (e) {
      throw DataException('Failed to fetch product by barcode: $e');
    }
  }

  @override
  Future<Product?> getProductBySku({
    required String tenantId,
    required String sku,
  }) async {
    try {
      final response = await supabase
          .from('products')
          .select('''
            *,
            inventory_categories(name)
          ''')
          .eq('tenant_id', tenantId)
          .eq('sku', sku)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return _productFromJson(response);
    } catch (e) {
      throw DataException('Failed to fetch product by SKU: $e');
    }
  }

  // Helper method to convert JSON to Product entity
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

  // Helper method to convert JSON to StockMovement entity
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
