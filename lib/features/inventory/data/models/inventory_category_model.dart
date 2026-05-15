import 'package:equatable/equatable.dart';

class InventoryCategoryModel extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String? parentCategoryId;
  final int productCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryCategoryModel({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.parentCategoryId,
    required this.productCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentCategoryId: json['parent_category_id'] as String?,
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'description': description,
      'parent_category_id': parentCategoryId,
      'product_count': productCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InventoryCategoryModel copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? description,
    String? parentCategoryId,
    int? productCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryCategoryModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        description,
        parentCategoryId,
        productCount,
        isActive,
        createdAt,
        updatedAt,
      ];
}
