
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_storage.dart';
import '../widgets/custom_textfield.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _category = TextEditingController();
  final _unit = TextEditingController(text: 'Pc');
  final _price = TextEditingController();
  final _quantity = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _category.dispose();
    _unit.dispose();
    _price.dispose();
    _quantity.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  String? _validPrice(String? v) {
    final n = double.tryParse(v ?? '');
    return n == null || !n.isFinite || n < 0
        ? 'Enter a valid price'
        : null;
  }

  String? _validQuantity(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n < 0 ? 'Enter a whole number' : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await ProductStorage.instance.addProduct(
        Product(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _name.text.trim(),
          sku: _sku.text.trim(),
          category: _category.text.trim(),
          unit: _unit.text.trim(),
          price: double.parse(_price.text.trim()),
          quantity: int.parse(_quantity.text.trim()),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save product: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _name,
                label: 'Product Name',
                validator: _required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _sku,
                label: 'SKU',
                validator: _required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _category,
                label: 'Category',
                validator: _required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _unit,
                label: 'Unit',
                validator: _required,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _price,
                label: 'Price',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validPrice,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _quantity,
                label: 'Quantity',
                keyboardType: TextInputType.number,
                validator: _validQuantity,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
