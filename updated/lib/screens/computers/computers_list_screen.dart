import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/computer.dart';

class ComputersListScreen extends StatelessWidget {
  const ComputersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.bgDark,
            AppTheme.primaryBlue.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Computers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.glowShadow(AppTheme.primaryBlue),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    onPressed: () {
                      _showAddComputerDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                    );
                  }

                  if (provider.computers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No computers yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadComputers(),
                    color: AppTheme.primaryBlue,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.computers.length,
                      itemBuilder: (context, index) {
                        return _buildComputerCard(
                          context,
                          provider.computers[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputerCard(BuildContext context, Computer computer) {
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);
    
    Color statusColor;
    LinearGradient statusGradient;
    IconData statusIcon;
    
    switch (computer.status) {
      case ComputerStatus.available:
        statusColor = AppTheme.successGreen;
        statusGradient = AppTheme.successGradient;
        statusIcon = Icons.check_circle;
        break;
      case ComputerStatus.sold:
        statusColor = AppTheme.errorRed;
        statusGradient = AppTheme.errorGradient;
        statusIcon = Icons.shopping_bag;
        break;
      case ComputerStatus.maintenance:
        statusColor = AppTheme.warningAmber;
        statusGradient = AppTheme.warningGradient;
        statusIcon = Icons.build_circle;
        break;
      case ComputerStatus.reserved:
        statusColor = AppTheme.primaryBlue;
        statusGradient = AppTheme.primaryGradient;
        statusIcon = Icons.bookmark;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showComputerDetails(context, computer);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.glowShadow(AppTheme.primaryBlue),
                ),
                child: const Icon(
                  Icons.computer_rounded,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      computer.model,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      computer.specs,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(computer.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status & Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: statusGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          computer.statusText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Qty: ${computer.quantity}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComputerDetails(BuildContext context, Computer computer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ComputerDetailsSheet(computer: computer),
    );
  }
}

class _ComputerDetailsSheet extends StatefulWidget {
  final Computer computer;
  
  const _ComputerDetailsSheet({required this.computer});
  
  @override
  State<_ComputerDetailsSheet> createState() => _ComputerDetailsSheetState();
}

class _ComputerDetailsSheetState extends State<_ComputerDetailsSheet> {
  late ComputerStatus _selectedStatus;
  final TextEditingController _quantityController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.computer.status;
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  Future<void> _handleStatusChange(BuildContext context, AppProvider provider) async {
    if (_selectedStatus == widget.computer.status) {
      Navigator.pop(context);
      return;
    }

    // If changing to "Sold", ask for quantity
    if (_selectedStatus == ComputerStatus.sold) {
      await _handleSoldStatus(context, provider);
    } else {
      // For other status changes, just update
      await _updateStatus(context, provider);
    }
  }

  Future<void> _handleSoldStatus(BuildContext context, AppProvider provider) async {
    // Show dialog to ask for quantity
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'Sell Units',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available: ${widget.computer.quantity} units',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Quantity to sell',
                hintText: 'Enter quantity',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(_quantityController.text);
              if (qty != null && qty > 0 && qty <= widget.computer.quantity) {
                Navigator.pop(context, qty);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invalid quantity. Must be between 1 and ${widget.computer.quantity}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (quantity != null && mounted) {
      try {
        // Call sellUnits API which handles creating sold items and updating quantity
        await provider.sellUnits(widget.computer.id!, quantity);
        
        if (context.mounted) {
          Navigator.pop(context); // Close details modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sold $quantity unit(s) successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error selling units: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateStatus(BuildContext context, AppProvider provider) async {
    try {
      final updatedComputer = Computer(
        id: widget.computer.id,
        model: widget.computer.model,
        specs: widget.computer.specs,
        price: widget.computer.price,
        quantity: widget.computer.quantity,
        status: _selectedStatus,
        saleDate: widget.computer.saleDate,
      );
      
      await provider.updateComputer(widget.computer.id!, updatedComputer);
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.computer.model,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Specs: ${widget.computer.specs}',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Price: ${NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2).format(widget.computer.price)}',
            style: const TextStyle(fontSize: 14, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            'Quantity: ${widget.computer.quantity}',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          // Status Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ComputerStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    dropdownColor: AppTheme.bgCard,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    items: ComputerStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList(),
                    onChanged: (ComputerStatus? newStatus) {
                      if (newStatus != null) {
                        setState(() => _selectedStatus = newStatus);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleStatusChange(context, provider),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getStatusText(ComputerStatus status) {
    switch (status) {
      case ComputerStatus.available:
        return 'Available';
      case ComputerStatus.sold:
        return 'Sold';
      case ComputerStatus.maintenance:
        return 'Maintenance';
      case ComputerStatus.reserved:
        return 'Reserved';
    }
  }
}

void _showAddComputerDialog(BuildContext context) {
    final modelController = TextEditingController();
    final specsController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Add Computer', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: modelController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: specsController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Specs'),
              ),
              TextField(
                controller: priceController,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: quantityController,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AppProvider>(context, listen: false);
              final computer = Computer(
                model: modelController.text,
                specs: specsController.text,
                price: double.tryParse(priceController.text) ?? 0,
                quantity: int.tryParse(quantityController.text) ?? 0,
              );
              
              try {
                await provider.addComputer(computer);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Computer added successfully'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
