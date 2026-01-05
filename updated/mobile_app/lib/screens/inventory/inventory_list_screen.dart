import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/computer_model.dart';
import 'computer_form_screen.dart';
import 'package:intl/intl.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatusChangeDialog(BuildContext context, Computer computer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select new status for ${computer.name}:'),
            SizedBox(height: 16),
            _StatusOption(
              status: 'available',
              currentStatus: computer.status,
              onTap: () {
                _updateStatus(context, computer, 'available');
                Navigator.pop(context);
              },
            ),
            _StatusOption(
              status: 'maintenance',
              currentStatus: computer.status,
              onTap: () {
                _updateStatus(context, computer, 'maintenance');
                Navigator.pop(context);
              },
            ),
            _StatusOption(
              status: 'sold',
              currentStatus: computer.status,
              onTap: () {
                _updateStatus(context, computer, 'sold');
                Navigator.pop(context);
              },
            ),
            _StatusOption(
              status: 'repair',
              currentStatus: computer.status,
              onTap: () {
                _updateStatus(context, computer, 'repair');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, Computer computer, String newStatus) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final updatedComputer = computer.copyWith(status: newStatus);
    inventoryProvider.updateComputer(computer.id!, updatedComputer);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to ${newStatus.toUpperCase()}'),
        backgroundColor: _getStatusColor(newStatus),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'sold':
        return Colors.blue;
      case 'repair':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'maintenance':
        return Icons.build_circle;
      case 'sold':
        return Icons.sell;
      case 'repair':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    List<Computer> filteredComputers = inventoryProvider.computers;
    if (_searchQuery.isNotEmpty) {
      filteredComputers = filteredComputers.where((computer) {
        final query = _searchQuery.toLowerCase();
        return computer.name.toLowerCase().contains(query) ||
            computer.brand.toLowerCase().contains(query) ||
            computer.category.toLowerCase().contains(query);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search computers...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: filteredComputers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No computers in inventory'
                        : 'No results found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredComputers.length,
              itemBuilder: (context, index) {
                final computer = filteredComputers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    // --- NEW FANCY IMAGE LEADING ---
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (computer.imageBase64 != null && computer.imageBase64!.isNotEmpty)
                            ? Image.memory(
                                base64Decode(computer.imageBase64!),
                                fit: BoxFit.cover,
                                // Fallback if the string is corrupted
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  _getCategoryIcon(computer.category),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : Icon(
                                _getCategoryIcon(computer.category),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            computer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(computer.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(computer.status),
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                computer.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${computer.brand} • ${computer.category}'),
                        Text(
                          '${computer.processor} • ${computer.ram} RAM',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: computer.quantity <= 5
                                    ? Colors.red.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Stock: ${computer.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: computer.quantity <= 5
                                      ? Colors.red.shade900
                                      : Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(computer.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        // Change Status Button
                        InkWell(
                          onTap: () => _showStatusChangeDialog(context, computer),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz, size: 12, color: Colors.grey.shade700),
                                SizedBox(width: 2),
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ComputerFormScreen(computer: computer),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ComputerFormScreen()),
          );
        },
        label: const Text('Add Computer'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop;
      case 'desktop':
        return Icons.computer;
      case 'server':
        return Icons.dns;
      case 'workstation':
        return Icons.work_outline;
      default:
        return Icons.devices;
    }
  }
}

class _StatusOption extends StatelessWidget {
  final String status;
  final String currentStatus;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.currentStatus,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'sold':
        return Colors.blue;
      case 'repair':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'maintenance':
        return Icons.build_circle;
      case 'sold':
        return Icons.sell;
      case 'repair':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = status == currentStatus;
    final color = _getStatusColor(status);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(status),
              color: color,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(Icons.check, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
