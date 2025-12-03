import 'package:flutter/material.dart';
import 'package:computer_shop_app/models/maintenance_job.dart';
import 'package:computer_shop_app/services/api_service.dart';

class AddMaintenanceJobScreen extends StatefulWidget {
  const AddMaintenanceJobScreen({super.key});

  @override
  State<AddMaintenanceJobScreen> createState() => _AddMaintenanceJobScreenState();
}

class _AddMaintenanceJobScreenState extends State<AddMaintenanceJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _computerModelController = TextEditingController();
  final _reportedIssueController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _computerModelController.dispose();
    _reportedIssueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newJob = MaintenanceJob(
        // id: "", // Let backend assign real ID
        id: null, // Let backend assign real ID
        customerName: _customerNameController.text.trim(),
        computerModel: _computerModelController.text.trim(),
        reportedIssue: _reportedIssueController.text.trim(),
        dateReported: DateTime.now(),
        status: MaintenanceStatus.Pending,
      );

      try {
        await _apiService.addMaintenanceJob(newJob);
        if (!mounted) return;
        Navigator.pop(context, true); // success → refresh list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Maintenance Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter customer name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _computerModelController,
                decoration: const InputDecoration(
                  labelText: 'Computer Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter computer model' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _reportedIssueController,
                decoration: const InputDecoration(
                  labelText: 'Reported Issue',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter the reported issue' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Add Job'),
                        onPressed: _submitForm,
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
