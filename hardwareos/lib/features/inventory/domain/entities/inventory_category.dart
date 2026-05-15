import 'package:equatable/equatable.dart';

/// Domain entity representing an Inventory Category.
class InventoryCategory extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? code;
  final String? description;
  final String? parentCategoryId;
  final int productCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryCategory({
    required this.id,
    required this.tenantId,
    required this.name,
    this.code,
    this.description,
    this.parentCategoryId,
    required this.productCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this is a sub-category
  bool get isSubCategory => parentCategoryId != null;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        code,
        description,
        parentCategoryId,
        productCount,
        isActive,
        createdAt,
        updatedAt,
      ];

  InventoryCategory copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? code,
    String? description,
    String? parentCategoryId,
    int? productCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryCategory(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
