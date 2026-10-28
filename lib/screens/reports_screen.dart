
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_storage.dart';
import '../widgets/stock_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
        SnackBar(content: Text('Could not load report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quantity = _products.fold<int>(
      0,
      (sum, p) => sum + p.quantity,
    );

    final value = _products.fold<double>(
      0,
      (sum, p) => sum + p.totalValue,
    );

    final lowStock = _products.where((p) => p.quantity <= 5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  StockCard(
                    title: 'Different Products',
                    value: '${_products.length}',
                    icon: Icons.inventory,
                  ),
                  StockCard(
                    title: 'Total Units',
                    value: '$quantity',
                    icon: Icons.numbers,
                    color: Colors.blue,
                  ),
                  StockCard(
                    title: 'Inventory Value',
                    value: '\$${value.toStringAsFixed(2)}',
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                  StockCard(
                    title: 'Low Stock Products',
                    value: '${lowStock.length}',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Low Stock Items (5 or fewer)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (lowStock.isEmpty)
                    const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('No low-stock products'),
                    )
                  else
                    ...lowStock.map(
                      (p) => ListTile(
                        title: Text(p.name),
                        subtitle: Text('SKU: ${p.sku}'),
                        trailing: Text('${p.quantity} ${p.unit}'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
