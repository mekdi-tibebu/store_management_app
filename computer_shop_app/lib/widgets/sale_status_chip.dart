// lib/widgets/sale_status_chip.dart
import 'package:flutter/material.dart';
import 'package:computer_shop_app/models/computer_sale.dart'; // Import the SaleStatus

class SaleStatusChip extends StatelessWidget {
  final SaleStatus status;

  const SaleStatusChip({super.key, required this.status});

  Color _getStatusColor(SaleStatus status) {
    switch (status) {
      case SaleStatus.Available:
        return Colors.green;
      case SaleStatus.Sold:
        return Colors.red;
      case SaleStatus.Reserved:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status.toDisplayString(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: _getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }
}