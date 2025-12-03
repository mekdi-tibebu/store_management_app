// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/models/computer_sale.dart';
// import 'package:computer_shop_app/services/api_service.dart';
// import 'package:computer_shop_app/widgets/sale_status_chip.dart';
// import 'package:computer_shop_app/screens/sale_detail_screen.dart';
// import 'package:computer_shop_app/screens/add_computer_sale_screen.dart';
// import 'package:intl/intl.dart';

// class SalesListScreen extends StatefulWidget {
//   const SalesListScreen({super.key});

//   @override
//   State<SalesListScreen> createState() => _SalesListScreenState();
// }

// class _SalesListScreenState extends State<SalesListScreen> {
//   late Future<List<ComputerSale>> _salesFuture;
//   final ApiService _apiService = ApiService();

//   final _currencyFormatter = NumberFormat.currency(
//     locale: 'en_ET',
//     symbol: 'ETB ',
//     decimalDigits: 2,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _fetchSales();
//   }

//   void _fetchSales() {
//     setState(() {
//       _salesFuture = _apiService.getComputerSales();
//     });
//   }

//   void _navigateToSaleDetail(ComputerSale sale) async {
//     final bool? shouldRefresh = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => SaleDetailScreen(sale: sale),
//       ),
//     );

//     if (shouldRefresh == true) {
//       _fetchSales();
//     }
//   }

//   void _navigateToAddComputerSaleScreen() async {
//     final bool? saleAdded = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const AddComputerSaleScreen(),
//       ),
//     );

//     if (saleAdded == true) {
//       _fetchSales();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('New computer added for sale!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // ✅ White background
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF007BFF), // ✅ Blue AppBar
//         title: const Text('Available Computers for Sale', style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: FutureBuilder<List<ComputerSale>>(
//         future: _salesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${snapshot.error}'),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF007BFF), // ✅ Blue button
//                     ),
//                     onPressed: _fetchSales,
//                     child: const Text('Retry', style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No computers for sale found.'));
//           } else {
//             return RefreshIndicator(
//               onRefresh: () async => _fetchSales(),
//               color: const Color(0xFF007BFF), // ✅ Blue refresh loader
//               child: ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) =>
//                     _buildSaleCard(snapshot.data![index]),
//               ),
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFF007BFF), // ✅ Blue FAB
//         onPressed: _navigateToAddComputerSaleScreen,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildSaleCard(ComputerSale sale) {
//     return Card(
//       color: Colors.white, // ✅ White card
//       shadowColor: Colors.grey.withOpacity(0.2),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: ListTile(
//         title: Text(sale.model, style: const TextStyle(fontWeight: FontWeight.w600)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Specs: ${sale.specs}'),
//             Text('Price: ${_currencyFormatter.format(sale.price)}'),
//             SaleStatusChip(status: sale.status), // ✅ Keeps original chip colors
//           ],
//         ),
//         trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF007BFF)), // ✅ Blue arrow
//         onTap: () => _navigateToSaleDetail(sale),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Management',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // fontFamily: 'Poppins', // You might need to add a custom font
      ),
      home: const SalesManagementScreen(),
    );
  }
}

class SalesManagementScreen extends StatefulWidget {
  const SalesManagementScreen({super.key});

  @override
  State<SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<SalesManagementScreen> {
  int _selectedIndex = 1; // 1 for 'Sales Management' which is 'My Order' equivalent

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different screens here
    if (index == 0) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else if (index == 1) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => SalesManagementScreen()));
    } else if (index == 2) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteScreen()));
    } else if (index == 3) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => MaintenanceHubScreen())); // Renamed from My Profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set Scaffold background to white
      appBar: AppBar(
        backgroundColor: Colors.white, // Set AppBar background to white
        elevation: 0,
        title: const Text(
          'Sales Management', // Changed title
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
            onPressed: () {
              // Handle shopping bag icon tap
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF673AB7), // Purple underline
                                  width: 2.5,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Computers for Sale', // Changed from My Order
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "History" tab removed
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.end,
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //         child: Text(
                    //           'History',
                    //           style: TextStyle(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.normal,
                    //             color: Colors.grey[600],
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                _buildComputerSaleCard(
                  context,
                  imageAsset: 'assets/computer1.png', // Placeholder image
                  computerName: 'Gaming Desktop Z-Pro',
                  entryDate: '2023-10-26',
                  quantity: 1,
                  status: 'Available',
                  price: 1250.00,
                ),
                const SizedBox(height: 16),
                _buildComputerSaleCard(
                  context,
                  imageAsset: 'assets/computer2.png', // Placeholder image
                  computerName: 'Laptop UltraBook X',
                  entryDate: '2023-10-25',
                  quantity: 1,
                  status: 'Sold',
                  price: 980.50,
                ),
                const SizedBox(height: 16),
                _buildComputerSaleCard(
                  context,
                  imageAsset: 'assets/computer3.png', // Placeholder image
                  computerName: 'Mini PC Home Edition',
                  entryDate: '2023-10-20',
                  quantity: 2,
                  status: 'Available',
                  price: 450.00,
                ),
                const SizedBox(height: 16),
                _buildComputerSaleCard(
                  context,
                  imageAsset: 'assets/computer4.png', // Placeholder image
                  computerName: 'Workstation Pro Max',
                  entryDate: '2023-10-18',
                  quantity: 1,
                  status: 'Available',
                  price: 2100.00,
                ),
              ],
            ),
          ),
          // "Add" button at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle "Add" button press
                  print('Add New Item button pressed!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7), // Purple
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                label: const Text(
                  'Add New Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF673AB7), // Purple
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), // Changed icon for Sales Management
            label: 'Sales Management', // Changed label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined), // Changed icon for Maintenance Hub
            label: 'Maintenance Hub', // Changed label
          ),
        ],
      ),
    );
  }

  Widget _buildComputerSaleCard(
    BuildContext context, {
    required String imageAsset,
    required String computerName,
    required String entryDate,
    required int quantity,
    required String status,
    required double price,
  }) {
    Color statusColor = status == 'Available' ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero, // Remove default card margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Card background white
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Computer Image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imageAsset), // Use AssetImage
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Added Expanded to ensure text doesn't overflow
                        child: Text(
                          computerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis, // Handle long names
                        ),
                      ),
                      const SizedBox(width: 8), // Spacing between name and status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Entry Date: $entryDate',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: $quantity',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align( // Align price to the left
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // "Detail" and "Tracking" buttons removed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}