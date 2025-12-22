import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/maintenance_job.dart';
import '../../models/computer.dart';

class MaintenanceListScreen extends StatelessWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.bgDark,
            AppTheme.warningAmber.withOpacity(0.05),
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
                    'Maintenance',
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
                        gradient: AppTheme.warningGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.glowShadow(AppTheme.warningAmber),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    onPressed: () {
                      _showAddMaintenanceDialog(context);
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
                      child: CircularProgressIndicator(color: AppTheme.warningAmber),
                    );
                  }

                  final maintenanceComputers = provider.computers
                      .where((c) => c.status == ComputerStatus.maintenance)
                      .toList();

                  if (provider.maintenanceJobs.isEmpty && maintenanceComputers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 80,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No maintenance jobs yet',
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
                    onRefresh: () async {
                      await Future.wait([
                        provider.loadMaintenanceJobs(),
                        provider.loadComputers(),
                      ]);
                    },
                    color: AppTheme.warningAmber,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (maintenanceComputers.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Computers in Maintenance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          ...maintenanceComputers.map(
                            (computer) => _buildComputerMaintenanceCard(context, computer),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (provider.maintenanceJobs.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Customer Maintenance Jobs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          ...provider.maintenanceJobs.map(
                            (job) => _buildMaintenanceCard(context, job),
                          ),
                        ],
                      ],
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

  Widget _buildComputerMaintenanceCard(BuildContext context, Computer computer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.warningGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.computer,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height:4),
                    Text(
                      'Quantity: ${computer.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.warningGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.build, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Maintenance',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildMaintenanceCard(BuildContext context, MaintenanceJob job) {
    Color statusColor;
    LinearGradient statusGradient;
    IconData statusIcon;
    
    switch (job.status) {
      case MaintenanceStatus.pending:
        statusColor = AppTheme.errorRed;
        statusGradient = AppTheme.errorGradient;
        statusIcon = Icons.pending;
        break;
      case MaintenanceStatus.inProgress:
        statusColor = AppTheme.warningAmber;
        statusGradient = AppTheme.warningGradient;
        statusIcon = Icons.autorenew;
        break;
      case MaintenanceStatus.completed:
        statusColor = AppTheme.successGreen;
        statusGradient = AppTheme.successGradient;
        statusIcon = Icons.check_circle;
        break;
      case MaintenanceStatus.cancelled:
        statusColor = AppTheme.textSecondary;
        statusGradient = LinearGradient(colors: [AppTheme.textSecondary, AppTheme.textTertiary]);
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showJobDetails(context, job),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.computerModel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customer: ${job.customerName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          job.statusText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.reportedIssue,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Reported: ${DateFormat('MMM dd, yyyy').format(job.dateReported)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetails(BuildContext context, MaintenanceJob job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              job.computerModel,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Customer: ${job.customerName}',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Issue: ${job.reportedIssue}',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            if (job.notes != null && job.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${job.notes}',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Status: ${job.statusText}',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Reported: ${DateFormat('MMM dd, yyyy').format(job.dateReported)}',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            if (job.dateCompleted != null) ...[
              const SizedBox(height: 8),
              Text(
                'Completed: ${DateFormat('MMM dd, yyyy').format(job.dateCompleted!)}',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMaintenanceDialog(BuildContext context) {
    final customerController = TextEditingController();
    final modelController = TextEditingController();
    final issueController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('New Maintenance Job', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              TextField(
                controller: modelController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Computer Model'),
              ),
              TextField(
                controller: issueController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Reported Issue'),
              ),
              TextField(
                controller: notesController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
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
              final job = MaintenanceJob(
                customerName: customerController.text,
                computerModel: modelController.text,
                reportedIssue: issueController.text,
                notes: notesController.text.isEmpty ? null : notesController.text,
                dateReported: DateTime.now(),
              );
              
              try {
                await provider.addMaintenanceJob(job);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maintenance job added successfully'),
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
}
