// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/models/maintenance_job.dart'; // Import the model
// import 'package:computer_shop_app/services/api_service.dart';
// import 'package:computer_shop_app/screens/maintenance_detail_screen.dart';
// import 'package:computer_shop_app/screens/add_maintenance_job_screen.dart';
// import 'package:computer_shop_app/widgets/status_chip.dart'; // Ensure this is imported
// import 'package:computer_shop_app/utils/date_extensions.dart';

// class MaintenanceListScreen extends StatefulWidget {
//   const MaintenanceListScreen({super.key});

//   @override
//   State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
// }

// class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
//   late Future<List<MaintenanceJob>> _jobsFuture;
//   // final MockApiService _apiService = MockApiService();
//   final ApiService _apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     _jobsFuture = _apiService.getMaintenanceJobs();
//   }

//   void _fetchJobs() {
//     setState(() {
//       _jobsFuture = _apiService.getMaintenanceJobs();
//     });
//   }

//   void _navigateToDetail(MaintenanceJob job) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MaintenanceDetailScreen(job: job),
//       ),
//     );
//     setState(() {
//       _jobsFuture = _apiService.getMaintenanceJobs();
//     });
//   }

//   void _navigateToAddJobScreen() async {
//     final bool? jobAdded = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddMaintenanceJobScreen(),
//       ),
//     );

//     if (jobAdded == true) {
//       _fetchJobs(); 
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('New maintenance job added!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Maintenance Jobs'),
//       ),
//       body: FutureBuilder<List<MaintenanceJob>>(
//         future: _jobsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No maintenance jobs found.'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final job = snapshot.data![index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                   child: ListTile(
//                     title: Text(job.customerName),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Model: ${job.computerModel}'),
//                         Text('Issue: ${job.reportedIssue}'),
//                         Text('Reported: ${job.dateReported.toLocal().toShortDateString()}'),
//                         StatusChip(status: job.status), // Corrected: pass status enum
//                       ],
//                     ),
//                     trailing: const Icon(Icons.arrow_forward_ios),
//                     onTap: () => _navigateToDetail(job),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _navigateToAddJobScreen, // Call the new method
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales & Maintenance App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white, // Set app-wide scaffold background to white
      ),
      home: SalesMaintenanceWrapper(), // A wrapper to show both screens for comparison
    );
  }
}

// Dummy data for maintenance items
class MaintenanceItem {
  final String name;
  final String status;
  final DateTime entryDate;
  final DateTime? completionDate;
  final String? clientName;
  final String imagePath;

  MaintenanceItem({
    required this.name,
    required this.status,
    required this.entryDate,
    this.completionDate,
    this.clientName,
    required this.imagePath,
  });
}

class SalesMaintenanceWrapper extends StatefulWidget {
  @override
  _SalesMaintenanceWrapperState createState() => _SalesMaintenanceWrapperState();
}

class _SalesMaintenanceWrapperState extends State<SalesMaintenanceWrapper> {
  int _selectedIndex = 3; // 0 for Home, 1 for Sales, 2 for Favorite, 3 for Maintenance

  static final List<Widget> _widgetOptions = <Widget>[
    Text('Home Screen (Placeholder)', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    SalesListScreen(),
    Text('Favorite Screen (Placeholder)', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    MaintenanceListScreen(),
    Text('Maintenance Hub (Placeholder)', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)), // This is just a placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), // Changed to bag for sales
            label: 'Sales Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), // Changed to settings for maintenance hub
            label: 'Maintenance Hub',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To show all labels
      ),
    );
  }
}

// Keeping SalesListScreen as is for comparison if needed
class SalesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sales Management', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50, // Lighter purple for selected
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Computers for Sale',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildSalesListItem(
                  context,
                  imagePath: 'assets/desktop.png',
                  title: 'Gaming Desktop Z-Pro',
                  entryDate: '2023-10-26',
                  qty: 1,
                  price: '\$1250.25',
                  status: 'Available',
                  statusColor: Colors.green,
                ),
                SizedBox(height: 15),
                _buildSalesListItem(
                  context,
                  imagePath: 'assets/laptop.png',
                  title: 'Laptop UltraBook X',
                  entryDate: '2023-10-25',
                  qty: 1,
                  price: '\$980.50',
                  status: 'Sold',
                  statusColor: Colors.red,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: Center(
                      child: Text(
                        'Detail',
                        style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Tracking',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSalesListItem(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String entryDate,
    required int qty,
    required String price,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Entry Date: $entryDate',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Qty: $qty',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// MODIFIED MaintenanceListScreen
class MaintenanceListScreen extends StatelessWidget {
  final List<MaintenanceItem> maintenanceItems = [
    MaintenanceItem(
      name: 'Gaming Desktop Z-Pro',
      status: 'In Progress',
      entryDate: DateTime(2023, 11, 1),
      clientName: 'Alice Johnson',
      imagePath: 'assets/desktop.png',
    ),
    MaintenanceItem(
      name: 'Laptop UltraBook X',
      status: 'Completed',
      entryDate: DateTime(2023, 10, 28),
      completionDate: DateTime(2023, 11, 2),
      clientName: 'Bob Williams',
      imagePath: 'assets/laptop.png',
    ),
    MaintenanceItem(
      name: 'Office Monitor M1',
      status: 'Pending',
      entryDate: DateTime(2023, 11, 3),
      clientName: 'Charlie Davis',
      imagePath: 'assets/monitor.png',
    ),
    MaintenanceItem(
      name: 'Server Rack S-500',
      status: 'Completed',
      entryDate: DateTime(2023, 10, 20),
      completionDate: DateTime(2023, 10, 25),
      clientName: 'David Lee',
      imagePath: 'assets/server_rack.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Explicitly set background to white
      appBar: AppBar(
        title: Text('Maintenance Hub', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white, // AppBar background also white
        elevation: 0,
      ),
      body: Column(
        children: [
          // Navigation section for "Computers for Maintenance"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Ensure white background for the tab container
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50, // Lighter purple for selected state
                        borderRadius: BorderRadius.circular(30),
                        // Removed extra border to get the exact sales screen look
                      ),
                      child: Text(
                        'Computers for Maintenance', // The desired navigation title
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                  // The 'History' tab is definitively REMOVED
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: maintenanceItems.length,
              itemBuilder: (context, index) {
                final item = maintenanceItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _buildMaintenanceListItem(context, item),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add computer logic
                  print('Add Computer for Maintenance');
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Computer for Maintenance',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMaintenanceListItem(BuildContext context, MaintenanceItem item) {
    Color statusColor;
    switch (item.status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Pending':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Entry Date: ${item.entryDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (item.status == 'Completed' && item.completionDate != null)
                        Text(
                          'Completion Date: ${item.completionDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Client Name at the right bottom corner of the card
            if (item.clientName != null) ...[
              SizedBox(height: 10), // Space between details and client name
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Client: ${item.clientName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}