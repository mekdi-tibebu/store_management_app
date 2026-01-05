import 'dart:convert';
import 'dart:io'; // Required for File
import 'package:flutter/foundation.dart' show kIsWeb; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/inventory_provider.dart';
import '../../models/computer_model.dart';

class ComputerFormScreen extends StatefulWidget {
  final Computer? computer;

  const ComputerFormScreen({super.key, this.computer});

  @override
  State<ComputerFormScreen> createState() => _ComputerFormScreenState();
}

class _ComputerFormScreenState extends State<ComputerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _processorController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _gpuController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final _costPriceController = TextEditingController();

  XFile? _pickedImage; 
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'Desktop';
  final List<String> _categories = ['Desktop', 'Laptop', 'Server', 'Workstation', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.computer != null) {
      _nameController.text = widget.computer!.name;
      _brandController.text = widget.computer!.brand;
      _processorController.text = widget.computer!.processor;
      _ramController.text = widget.computer!.ram;
      _storageController.text = widget.computer!.storage;
      _gpuController.text = widget.computer!.gpu;
      _priceController.text = widget.computer!.price.toString();
      _costPriceController.text = widget.computer!.costPrice.toString();
      _quantityController.text = widget.computer!.quantity.toString();
      _descriptionController.text = widget.computer!.description;
      
      if (_categories.contains(widget.computer!.category)) {
        _selectedCategory = widget.computer!.category;
      } else {
        _selectedCategory = 'Other';
        _otherCategoryController.text = widget.computer!.category;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _gpuController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    String? base64String;
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      base64String = base64Encode(bytes);
    }

    String finalCategory = _selectedCategory == 'Other' 
        ? _otherCategoryController.text.trim() 
        : _selectedCategory;

    final computer = Computer(
      id: widget.computer?.id,
      userId: widget.computer?.userId ?? currentUid,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      category: finalCategory,
      processor: _processorController.text.trim(),
      ram: _ramController.text.trim(),
      storage: _storageController.text.trim(),
      gpu: _gpuController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      description: _descriptionController.text.trim(),
      status: widget.computer?.status ?? 'available',
      createdAt: widget.computer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      imageBase64: base64String ?? widget.computer?.imageBase64,
    );

    bool success;
    if (widget.computer != null) {
      success = await inventoryProvider.updateComputer(widget.computer!.id!, computer);
    } else {
      success = await inventoryProvider.addComputer(computer);
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(inventoryProvider.errorMessage ?? 'Failed to save')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        // On web, XFile.path is a blob URL, so Image.network is used
        child: kIsWeb 
          ? Image.network(_pickedImage!.path, fit: BoxFit.cover, width: double.infinity)
          : Image.file(File(_pickedImage!.path), fit: BoxFit.cover, width: double.infinity),
      );
    }
    if (widget.computer?.imageBase64 != null && widget.computer!.imageBase64!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(base64Decode(widget.computer!.imageBase64!), fit: BoxFit.cover, width: double.infinity),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.indigo),
        SizedBox(height: 8),
        Text("Upload Product Photo", style: TextStyle(color: Colors.indigo)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.computer != null ? 'Edit Computer' : 'Add Computer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- IMAGE PICKER MOVED INSIDE CHILDREN ---
            GestureDetector(
              onTap: () async {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 30, // Highly compressed for Firestore Base64 storage
                );
                if (image != null) setState(() => _pickedImage = image);
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                ),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Computer Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            if (_selectedCategory == 'Other') ...[
              TextFormField(
                controller: _otherCategoryController,
                decoration: const InputDecoration(labelText: 'Enter Custom Category'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (_selectedCategory == 'Other' && (v == null || v.isEmpty)) 
                    ? 'Please specify' 
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _processorController,
              decoration: const InputDecoration(labelText: 'Processor'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ramController,
              decoration: const InputDecoration(labelText: 'RAM (e.g., 16GB)'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _storageController,
              decoration: const InputDecoration(labelText: 'Storage (e.g., 512GB SSD)'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Selling Price', prefixText: 'ETB '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _costPriceController,
              decoration: const InputDecoration(labelText: 'Buying Price (Cost)', prefixText: 'ETB '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(widget.computer != null ? 'Update Computer' : 'Add Computer'),
            ),
          ],
        ),
      ),
    );
  }
}