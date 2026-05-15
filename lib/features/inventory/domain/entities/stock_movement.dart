import 'package:equatable/equatable.dart';

/// Domain entity representing a stock movement transaction.
/// Tracks all inventory changes (in/out/adjustment/transfer).
class StockMovement extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final String productName;
  final String productSku;
  final MovementType movementType;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String? referenceId;
  final String? referenceType;
  final String? warehouseId;
  final String? warehouseName;
  final String? reason;
  final String performedBy;
  final String performedByName;
  final DateTime movementDate;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.movementType,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.referenceId,
    this.referenceType,
    this.warehouseId,
    this.warehouseName,
    this.reason,
    required this.performedBy,
    required this.performedByName,
    required this.movementDate,
    required this.createdAt,
  });

  /// Check if this is an incoming movement
  bool get isIncoming => 
      movementType == MovementType.receive ||
      movementType == MovementType.adjustmentIn ||
      movementType == MovementType.returnIn;

  /// Check if this is an outgoing movement
  bool get isOutgoing => 
      movementType == MovementType.sale ||
      movementType == MovementType.adjustmentOut ||
      movementType == MovementType.transferOut ||
      movementType == MovementType.damage ||
      movementType == MovementType.loss;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        productId,
        productName,
        productSku,
        movementType,
        quantity,
        stockBefore,
        stockAfter,
        referenceId,
        referenceType,
        warehouseId,
        warehouseName,
        reason,
        performedBy,
        performedByName,
        movementDate,
        createdAt,
      ];
}

/// Types of stock movements
enum MovementType {
  receive,        // Receiving from supplier
  sale,           // Sold to customer
  adjustmentIn,   // Manual stock increase
  adjustmentOut,  // Manual stock decrease
  transferIn,     // Transfer from another warehouse
  transferOut,    // Transfer to another warehouse
  returnIn,       // Customer return
  returnOut,      // Return to supplier
  damage,         // Damaged goods
  loss,           // Lost/stolen items
}

/// Extension for display names
extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.receive:
        return 'Receive';
      case MovementType.sale:
        return 'Sale';
      case MovementType.adjustmentIn:
        return 'Adjustment In';
      case MovementType.adjustmentOut:
        return 'Adjustment Out';
      case MovementType.transferIn:
        return 'Transfer In';
      case MovementType.transferOut:
        return 'Transfer Out';
      case MovementType.returnIn:
        return 'Return In';
      case MovementType.returnOut:
        return 'Return Out';
      case MovementType.damage:
        return 'Damage';
      case MovementType.loss:
        return 'Loss';
    }
  }

  String get iconCode {
    switch (this) {
      case MovementType.receive:
        return '📥';
      case MovementType.sale:
        return '💰';
      case MovementType.adjustmentIn:
      case MovementType.adjustmentOut:
        return '🔧';
      case MovementType.transferIn:
      case MovementType.transferOut:
        return '🚚';
      case MovementType.returnIn:
      case MovementType.returnOut:
        return '↩️';
      case MovementType.damage:
        return '⚠️';
      case MovementType.loss:
        return '❌';
    }
  }
}
