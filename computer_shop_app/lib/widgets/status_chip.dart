// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/models/maintenance_job.dart'; // Import the model

// class StatusChip extends StatelessWidget {
//   final MaintenanceStatus status;

//   const StatusChip({super.key, required this.status});

//   Color _getStatusColor(MaintenanceStatus status) {
//     switch (status) {
//       case MaintenanceStatus.Pending:
//         return Colors.orange;
//       case MaintenanceStatus.InProgress:
//         return Colors.blue;
//       case MaintenanceStatus.Completed:
//         return Colors.green;
//       case MaintenanceStatus.Cancelled:
//         return Colors.red;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text(
//         status.toDisplayString(),
//         style: const TextStyle(color: Colors.white),
//       ),
//       backgroundColor: _getStatusColor(status),
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:computer_shop_app/models/maintenance_job.dart';

class StatusChip extends StatelessWidget {
  final MaintenanceStatus status;

  const StatusChip({super.key, required this.status});

  Color _getStatusColor(BuildContext context, MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.Pending:
        return Colors.orange.shade700;
      case MaintenanceStatus.InProgress:
        return Theme.of(context).colorScheme.primary;
      case MaintenanceStatus.Completed:
        return Colors.green.shade700;
      case MaintenanceStatus.Cancelled:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context, status);
    return Chip(
      label: Text(
        status.toDisplayString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
