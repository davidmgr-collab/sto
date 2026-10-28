
import '../models/product.dart';
import 'database_helper.dart';

Future<void> seedProducts() async {
  final db = DatabaseHelper.instance;

  // Do not seed if products already exist.
  if (await db.getProductCount() > 0) {
    return;
  }

  await db.insertProduct(
    const Product(
      id: '',
      name: 'Laptop',
      sku: 'LP001',
      category: 'Electronics',
      unit: 'Pc',
      price: 800,
      quantity: 20,
    ),
  );

  await db.insertProduct(
    const Product(
      id: '',
      name: 'Mouse',
      sku: 'MS001',
      category: 'Accessories',
      unit: 'Pc',
      price: 10,
      quantity: 150,
    ),
  );
}
