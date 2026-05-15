import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Equatable {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String sku;
  final String? barcode;
  final String categoryId;
  final String categoryName;
  final double unitPrice;
  final double costPrice;
  final String unitOfMeasure;
  final int stockQuantity;
  final int reorderPoint;
  final String? warehouseLocation;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.sku,
    this.barcode,
    required this.categoryId,
    required this.categoryName,
    required this.unitPrice,
    required this.costPrice,
    required this.unitOfMeasure,
    required this.stockQuantity,
    required this.reorderPoint,
    this.warehouseLocation,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductModel copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    double? unitPrice,
    double? costPrice,
    String? unitOfMeasure,
    int? stockQuantity,
    int? reorderPoint,
    String? warehouseLocation,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      imageUrl: imageUrl ?? this.imageUrl,
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
        sku,
        barcode,
        categoryId,
        categoryName,
        unitPrice,
        costPrice,
        unitOfMeasure,
        stockQuantity,
        reorderPoint,
        warehouseLocation,
        imageUrl,
        isActive,
        createdAt,
        updatedAt,
      ];

  bool get isLowStock => stockQuantity <= reorderPoint;
  bool get isOutOfStock => stockQuantity == 0;
}
