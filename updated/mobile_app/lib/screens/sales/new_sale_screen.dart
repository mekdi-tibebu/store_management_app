import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/sales_provider.dart';
import '../../models/computer_model.dart';
import '../../models/sale_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final List<SaleItem> _cartItems = [];
  final currencyFormatter = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }


  void _addToCart(Computer computer) {
    final existingIndex = _cartItems.indexWhere((item) => item.computerId == computer.id);
    
    if (existingIndex >= 0) {
      final currentQty = _cartItems[existingIndex].quantity;
      if (currentQty >= computer.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient stock')));
        return;
      }
      
      setState(() {
        final newQty = currentQty + 1;
        _cartItems[existingIndex] = SaleItem(
          computerId: computer.id!,
          computerName: computer.name,
          quantity: newQty,
          unitPrice: computer.price,
          // NEW: Store cost price in the cart item
          costPrice: computer.costPrice, 
          totalPrice: computer.price * newQty,
        );
      });
    } else {
      setState(() {
        _cartItems.add(SaleItem(
          computerId: computer.id!,
          computerName: computer.name,
          quantity: 1,
          unitPrice: computer.price,
          costPrice: computer.costPrice, // NEW: Capture cost at time of sale
          totalPrice: computer.price,
        ));
      });
    }
  }

  // NEW: Calculate Total Cost for the whole cart
  double get totalCost {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.costPrice * item.quantity));
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQty, Computer computer) {
    if (newQty <= 0) {
      _removeFromCart(index);
      return;
    }
    
    if (newQty > computer.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max available: ${computer.quantity}')),
      );
      return;
    }

    setState(() {
      _cartItems[index] = SaleItem(
        computerId: computer.id!,
        computerName: computer.name,
        quantity: newQty,
        unitPrice: computer.price,
        costPrice: computer.costPrice,
        totalPrice: computer.price * newQty,
      );
    });
  }

  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _completeSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cartItems.isEmpty) return;

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    double totalCostCalculated = _cartItems.fold(0, (sum, item) => sum + (item.costPrice * item.quantity));


    // 1. Prepare the Sale object with P&L data
    final sale = Sale(
      userId: currentUid,
      saleNumber: salesProvider.generateSaleNumber(),
      customerId: '',
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      items: _cartItems,
      subtotal: subtotal,
      tax: 0,
      total: subtotal, // This is your 'Revenue'
      
      // CRITICAL FOR REPORTS:
      totalCost: totalCost, 
      profit: subtotal - totalCost,
      
      paymentMethod: 'Cash',
      createdAt: DateTime.now(),
    );

    // 2. Save to Firebase
    final success = await salesProvider.createSale(sale);

    if (mounted && success) {
      // 3. Update Inventory Stock (Decrease quantity)
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      for (var cartItem in _cartItems) {
        final computer = inventoryProvider.computers.firstWhere((c) => c.id == cartItem.computerId);
        int remainingQty = computer.quantity - cartItem.quantity;
        
        await inventoryProvider.updateComputer(
          computer.id!, 
          computer.copyWith(
            quantity: remainingQty,
            status: remainingQty <= 0 ? 'sold' : computer.status,
          ),
        );
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale Completed & Inventory Updated'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
      ),
      body: Column(
        children: [
          // Customer Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),

          // Cart Items
          if (_cartItems.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _cartItems.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  final computer = inventoryProvider.computers
                      .firstWhere((c) => c.id == item.computerId);

                  return ListTile(
                    title: Text(item.computerName),
                    subtitle: Text(currencyFormatter.format(item.unitPrice)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _updateQuantity(
                            index,
                            item.quantity - 1,
                            computer,
                          ),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _updateQuantity(
                            index,
                            item.quantity + 1,
                            computer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currencyFormatter.format(item.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Add items to cart'),
                  ],
                ),
              ),
            ),

          // Available Products
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Available Products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: inventoryProvider.computers
                  .where((c) => c.quantity > 0)
                  .length,
              itemBuilder: (context, index) {
                final computer = inventoryProvider.computers
                    .where((c) => c.quantity > 0)
                    .toList()[index];

                return Card(
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => _addToCart(computer),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            computer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(computer.price),
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                          const Spacer(),
                          Text(
                            'Stock: ${computer.quantity}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Total and Complete
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        currencyFormatter.format(subtotal),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeSale,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Complete Sale'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
