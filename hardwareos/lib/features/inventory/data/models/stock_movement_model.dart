import 'package:equatable/equatable.dart';

enum StockMovementType {
  receive,
  adjustIn,
  adjustOut,
  transfer,
  sale,
  returnItem,
}

class StockMovementModel extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final String productName;
  final String sku;
  final StockMovementType movementType;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String? referenceId;
  final String? referenceType;
  final String? reason;
  final String performedBy;
  final String performedByName;
  final String? warehouseLocation;
  final DateTime movementDate;
  final DateTime createdAt;

  const StockMovementModel({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.movementType,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.referenceId,
    required this.referenceType,
    this.reason,
    required this.performedBy,
    required this.performedByName,
    this.warehouseLocation,
    required this.movementDate,
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      sku: json['sku'] as String,
      movementType: StockMovementType.values.firstWhere(
        (e) => e.name == json['movement_type'],
        orElse: () => StockMovementType.adjustIn,
      ),
      quantity: (json['quantity'] as num).toInt(),
      stockBefore: (json['stock_before'] as num).toInt(),
      stockAfter: (json['stock_after'] as num).toInt(),
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      reason: json['reason'] as String?,
      performedBy: json['performed_by'] as String,
      performedByName: json['performed_by_name'] as String,
      warehouseLocation: json['warehouse_location'] as String?,
      movementDate: DateTime.parse(json['movement_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'movement_type': movementType.name,
      'quantity': quantity,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'reason': reason,
      'performed_by': performedBy,
      'performed_by_name': performedByName,
      'warehouse_location': warehouseLocation,
      'movement_date': movementDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  StockMovementModel copyWith({
    String? id,
    String? tenantId,
    String? productId,
    String? productName,
    String? sku,
    StockMovementType? movementType,
    int? quantity,
    int? stockBefore,
    int? stockAfter,
    String? referenceId,
    String? referenceType,
    String? reason,
    String? performedBy,
    String? performedByName,
    String? warehouseLocation,
    DateTime? movementDate,
    DateTime? createdAt,
  }) {
    return StockMovementModel(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      stockBefore: stockBefore ?? this.stockBefore,
      stockAfter: stockAfter ?? this.stockAfter,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      reason: reason ?? this.reason,
      performedBy: performedBy ?? this.performedBy,
      performedByName: performedByName ?? this.performedByName,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      movementDate: movementDate ?? this.movementDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        productId,
        productName,
        sku,
        movementType,
        quantity,
        stockBefore,
        stockAfter,
        referenceId,
        referenceType,
        reason,
        performedBy,
        performedByName,
        warehouseLocation,
        movementDate,
        createdAt,
      ];
}
