
class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unit;
  final double price;
  final int quantity;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get totalValue => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'unit': unit,
      'price': price,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'].toString(),
      sku: map['sku'].toString(),
      category: map['category'].toString(),
      unit: map['unit'].toString(),
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  Product copyWith({
    String? name,
    String? sku,
    String? category,
    String? unit,
    double? price,
    int? quantity,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
