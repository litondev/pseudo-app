class Product {
  final int? id;
  final String? name;
  final double? price;
  final double? stock;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

 const Product({
    this.id,
    this.name,
    this.price,
    this.stock,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      stock: json['stock'] != null ? (json['stock'] as num).toDouble() : null,
      image: json['image'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  // Method to convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Method to create a copy of Product with updated fields
  Product copyWith({
    int? id,
    String? name,
    double? price,
    double? stock,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, stock: $stock, image: $image, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          stock == other.stock &&
          image == other.image;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode ^ stock.hashCode ^ image.hashCode;
}