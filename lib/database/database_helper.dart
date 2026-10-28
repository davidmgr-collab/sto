
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import 'database_factory.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final factory = createDatabaseFactory();
    final directory = await factory.getDatabasesPath();
    final dbPath = join(directory, 'stock_management.db');

    _database = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              sku TEXT NOT NULL UNIQUE,
              category TEXT NOT NULL,
              unit TEXT NOT NULL,
              price REAL NOT NULL,
              quantity INTEGER NOT NULL
            )
          ''');
        },
      ),
    );

    return _database!;
  }

  // Insert a new product
  Future<int> insertProduct(Product product) async {
    final db = await database;
    final values = product.toMap()..remove('id');

    return db.insert(
      'products',
      values,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Get all products
  Future<List<Product>> getProducts() async {
    final db = await database;

    final rows = await db.query(
      'products',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map((row) => Product.fromMap(row)).toList();
  }

  // Update an existing product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    final values = product.toMap()..remove('id');

    return db.update(
      'products',
      values,
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Delete a product by ID
  Future<int> deleteProduct(int id) async {
    final db = await database;

    return db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Count all products
  Future<int> getProductCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM products',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Calculate the total value of stock
  Future<double> getTotalStockValue() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(price * quantity), 0) AS total '
      'FROM products',
    );

    return (result.first['total'] as num).toDouble();
  }

  // Count products at or below the stock threshold
  Future<int> getLowStockCount({int threshold = 5}) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total '
      'FROM products WHERE quantity <= ?',
      [threshold],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
