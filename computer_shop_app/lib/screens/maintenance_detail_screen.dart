// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/models/maintenance_job.dart';
// import 'package:computer_shop_app/services/api_service.dart';
// import 'package:computer_shop_app/utils/date_extensions.dart';

// class MaintenanceDetailScreen extends StatefulWidget {
//   final MaintenanceJob job;

//   const MaintenanceDetailScreen({super.key, required this.job});

//   @override
//   State<MaintenanceDetailScreen> createState() =>
//       _MaintenanceDetailScreenState();
// }

// class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
//   final ApiService _apiService = ApiService();

//   late TextEditingController _customerController;
//   late TextEditingController _modelController;
//   late TextEditingController _issueController;
//   late TextEditingController _notesController;
//   late MaintenanceStatus _selectedStatus;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _customerController =
//         TextEditingController(text: widget.job.customerName);
//     _modelController = TextEditingController(text: widget.job.computerModel);
//     _issueController = TextEditingController(text: widget.job.reportedIssue);
//     _notesController = TextEditingController(text: widget.job.notes ?? "");
//     _selectedStatus = widget.job.status;
//   }

//   @override
//   void dispose() {
//     _customerController.dispose();
//     _modelController.dispose();
//     _issueController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveChanges() async {
//     setState(() => _isLoading = true);
//     try {
//       final updatedJob = widget.job.copyWith(
//         customerName: _customerController.text,
//         computerModel: _modelController.text,
//         reportedIssue: _issueController.text,
//         notes: _notesController.text,
//         status: _selectedStatus,
//         dateCompleted: _selectedStatus == MaintenanceStatus.Completed
//             ? DateTime.now()
//             : null,
//       );

//       await _apiService.updateMaintenanceJob(updatedJob);

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Maintenance job updated successfully")),
//       );
//       Navigator.pop(context, true); // refresh list
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _deleteJob() async {
//     setState(() => _isLoading = true);
//     try {
//       await _apiService.deleteMaintenanceJob(widget.job.id!.toString());

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Maintenance job deleted")),
//       );
//       Navigator.pop(context, true); // refresh list
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to delete: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Edit Job ${widget.job.id}")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _customerController,
//                     decoration:
//                         const InputDecoration(labelText: "Customer Name"),
//                   ),
//                   const SizedBox(height: 12),

//                   TextField(
//                     controller: _modelController,
//                     decoration:
//                         const InputDecoration(labelText: "Computer Model"),
//                   ),
//                   const SizedBox(height: 12),

//                   TextField(
//                     controller: _issueController,
//                     decoration:
//                         const InputDecoration(labelText: "Reported Issue"),
//                     maxLines: 2,
//                   ),
//                   const SizedBox(height: 12),

//                   TextField(
//                     controller: _notesController,
//                     decoration: const InputDecoration(labelText: "Notes"),
//                     maxLines: 2,
//                   ),
//                   const SizedBox(height: 12),

//                   DropdownButtonFormField<MaintenanceStatus>(
//                     value: _selectedStatus,
//                     decoration: const InputDecoration(labelText: "Status"),
//                     items: MaintenanceStatus.values.map((status) {
//                       return DropdownMenuItem(
//                         value: status,
//                         child: Text(status.toDisplayString()),
//                       );
//                     }).toList(),
//                     onChanged: (val) {
//                       if (val != null) setState(() => _selectedStatus = val);
//                     },
//                   ),
//                   const SizedBox(height: 24),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.save),
//                           label: const Text("Save"),
//                           onPressed: _saveChanges,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.delete),
//                           label: const Text("Delete"),
//                           onPressed: _deleteJob,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class MaintenanceDetailPage extends StatefulWidget {
  @override
  _MaintenanceDetailPageState createState() => _MaintenanceDetailPageState();
}

class _MaintenanceDetailPageState extends State<MaintenanceDetailPage> {
  String _selectedStatus = 'Completed'; // Initial status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Maintenance Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      'https://via.placeholder.com/150', // Replace with an actual image URL for the computer
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Computer Name: Gaming Desktop Z-Pro',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Full system diagnostic, dust removal & internal cleaning, cooling system check (liquid lighting), software updates & performance benchmark.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entry Date: 2024-03-15',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Completion Date: 2024-03-17',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client Name: John Smith',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        icon: Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                        items: <String>['Scheduled', 'In Progress', 'Completed', 'Cancelled']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle delete action
                        print('Delete button pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle edit action
                        print('Edit button pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  '[Last Updated: 2024-03-17]', // Replace with dynamic last updated date
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MaintenanceDetailPage(),
  ));
}