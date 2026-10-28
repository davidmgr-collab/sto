
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class ProductStorage {
  ProductStorage._();

  static final ProductStorage instance = ProductStorage._();

  static const String _storageKey = 'stock_management_products';

  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      final samples = <Product>[
        const Product(
          id: 'sample-laptop',
          name: 'Laptop',
          sku: 'LP001',
          category: 'Electronics',
          unit: 'Pc',
          price: 800,
          quantity: 20,
        ),
        const Product(
          id: 'sample-mouse',
          name: 'Mouse',
          sku: 'MS001',
          category: 'Accessories',
          unit: 'Pc',
          price: 10,
          quantity: 150,
        ),
      ];

      await _save(samples);
      return samples;
    }

    final decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded.map((item) {
      return Product.fromMap(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  Future<void> _save(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(products.map((p) => p.toMap()).toList()),
    );
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();

    final duplicate = products.any(
      (p) => p.sku.toLowerCase() == product.sku.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('A product with this SKU already exists.');
    }

    products.add(product);
    await _save(products);
  }

  Future<void> updateProduct(Product updated) async {
    final products = await getProducts();

    final duplicate = products.any(
      (p) =>
          p.id != updated.id &&
          p.sku.toLowerCase() == updated.sku.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('A product with this SKU already exists.');
    }

    final index = products.indexWhere((p) => p.id == updated.id);

    if (index == -1) {
      throw Exception('Product not found.');
    }

    products[index] = updated;
    await _save(products);
  }

  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == id);
    await _save(products);
  }
}
