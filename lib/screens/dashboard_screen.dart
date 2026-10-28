
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_storage.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/stock_card.dart';
import 'add_product_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await ProductStorage.instance.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load products: $e')),
      );
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final lowStock = _products.where((p) => p.quantity <= 5).length;
    final stockValue = _products.fold<double>(
      0,
      (sum, p) => sum + p.totalValue,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Dashboard Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  StockCard(
                    title: 'Total Products',
                    value: '${_products.length}',
                    icon: Icons.inventory_2,
                  ),
                  StockCard(
                    title: 'Low Stock Products',
                    value: '$lowStock',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                  StockCard(
                    title: 'Total Stock Value',
                    value: '\$${stockValue.toStringAsFixed(2)}',
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      DashboardCard(
                        title: 'Add Product',
                        icon: Icons.add_box,
                        onTap: () => _open(const AddProductScreen()),
                      ),
                      DashboardCard(
                        title: 'View Products',
                        icon: Icons.inventory,
                        onTap: () => _open(const ProductsScreen()),
                      ),
                      DashboardCard(
                        title: 'Reports',
                        icon: Icons.bar_chart,
                        onTap: () => _open(const ReportsScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
