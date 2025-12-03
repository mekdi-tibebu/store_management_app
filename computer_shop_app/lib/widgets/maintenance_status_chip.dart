// lib/widgets/maintenance_status_chip.dart (or wherever you put your widgets)
import 'package:flutter/material.dart';
import 'package:computer_shop_app/models/maintenance_job.dart';

class MaintenanceStatusChip extends StatelessWidget {
  final MaintenanceStatus status;

  const MaintenanceStatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Customize how you want to display the maintenance status
    Color chipColor;
    String statusText;

    switch (status) {
      case MaintenanceStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case MaintenanceStatus.inProgress:
        chipColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case MaintenanceStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case MaintenanceStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
      // Add other cases as needed
    }

    return Chip(
      backgroundColor: chipColor.withOpacity(0.2),
      label: Text(
        statusText,
        style: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}