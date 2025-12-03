import 'package:flutter/material.dart';
import 'package:computer_shop_app/models/computer_sale.dart';
import 'package:computer_shop_app/services/api_service.dart';

class AddComputerSaleScreen extends StatefulWidget {
  const AddComputerSaleScreen({super.key});

  @override
  State<AddComputerSaleScreen> createState() => _AddComputerSaleScreenState();
}

class _AddComputerSaleScreenState extends State<AddComputerSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _specsController = TextEditingController();
  final _priceController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _modelController.dispose();
    _specsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newSale = ComputerSale(
      id: 'S${DateTime.now().millisecondsSinceEpoch}', // unique ID
      model: _modelController.text.trim(),
      specs: _specsController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      status: SaleStatus.Available,
    );

    try {
      await _apiService.addComputerSale(newSale);
      if (!mounted) return;
      Navigator.pop(context, true); // return success flag
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add sale: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Computer for Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Computer Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter the model' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specsController,
                decoration: const InputDecoration(
                  labelText: 'Specifications',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter specs' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: 'ETB ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add Computer for Sale'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
