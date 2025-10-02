import 'user.dart';
import 'warehouse.dart';
import 'product.dart';

class Transaction {
  final int? id;
  final int? userId;
  final int? warehouseId;
  final int? productId;
  final String? type; // 'in' or 'out'
  final double? quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relationships
  final User? user;
  final Warehouse? warehouse;
  final Product? product;

  Transaction({
    this.id,
    this.userId,
    this.warehouseId,
    this.productId,
    this.type,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.warehouse,
    this.product,
  });

  // Factory constructor to create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      warehouseId: json['warehouse_id'],
      productId: json['product_id'],
      type: json['type'],
      quantity: json['quantity']?.toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      warehouse: json['warehouse'] != null ? Warehouse.fromJson(json['warehouse']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  // Method to convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'warehouse_id': warehouseId,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'warehouse': warehouse?.toJson(),
      'product': product?.toJson(),
    };
  }

  // Method to create a copy of Transaction with updated fields
  Transaction copyWith({
    int? id,
    int? userId,
    int? warehouseId,
    int? productId,
    String? type,
    double? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    Warehouse? warehouse,
    Product? product,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      warehouseId: warehouseId ?? this.warehouseId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      warehouse: warehouse ?? this.warehouse,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, userId: $userId, warehouseId: $warehouseId, productId: $productId, type: $type, quantity: $quantity, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          warehouseId == other.warehouseId &&
          productId == other.productId &&
          type == other.type &&
          quantity == other.quantity;

  @override
  int get hashCode => 
      id.hashCode ^ 
      userId.hashCode ^ 
      warehouseId.hashCode ^ 
      productId.hashCode ^ 
      type.hashCode ^ 
      quantity.hashCode;
}