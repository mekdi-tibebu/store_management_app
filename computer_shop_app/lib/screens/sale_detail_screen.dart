import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Computer Detail',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // fontFamily: 'Poppins', // You might need to add a custom font
      ),
      home: ComputerDetailPage(
        computerName: 'Gaming Desktop Z-Pro',
        price: 1250.25,
        descriptionPoints: const [
          'High-performance Intel i9 processor',
          'NVIDIA GeForce RTX 4080 graphics card',
          '32GB DDR5 RAM, 1TB NVMe SSD storage',
          'Liquid cooling system for optimal thermals',
          'Customizable RGB lighting',
          'Windows 11 Pro pre-installed',
        ],
        entryDate: '2023-10-26',
        stockQuantity: 10, // Example stock quantity
        status: 'Available', // Can be 'Available' or 'Sold'
        soldDate: null, // Set to '2023-11-01' if status is 'Sold'
      ),
    );
  }
}

class ComputerDetailPage extends StatefulWidget {
  final String computerName;
  final double price;
  final List<String> descriptionPoints;
  final String entryDate;
  final int stockQuantity;
  final String status;
  final String? soldDate;

  const ComputerDetailPage({
    super.key,
    required this.computerName,
    required this.price,
    required this.descriptionPoints,
    required this.entryDate,
    required this.stockQuantity,
    required this.status,
    this.soldDate,
  });

  @override
  State<ComputerDetailPage> createState() => _ComputerDetailPageState();
}

class _ComputerDetailPageState extends State<ComputerDetailPage> {
  late int _selectedQuantity; // Track selected quantity for the + / - buttons

  @override
  void initState() {
    super.initState();
    _selectedQuantity = widget.status == 'Available' ? 1 : 0; // Default to 1 if available, 0 if sold
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = widget.status == 'Available' ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white, // Ensure scaffold background is white
      extendBodyBehindAppBar: true, // Allow body to go behind transparent app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Product',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 8), // Keep consistent spacing if actions are empty
        ],
      ),
      body: Stack(
        children: [
          // Background Image (larger and towards the top)
          Positioned(
            left: 0,
            right: 0,
            top: 0, // Starts from the very top (behind the app bar)
            height: MediaQuery.of(context).size.height * 0.55, // Covers more area
            child: Container(
              color: Colors.grey[100], // Light background for the image area itself
              child: Image.asset(
                'assets/computer_image.png', // Placeholder for computer image
                fit: BoxFit.contain, // Ensures the image is fully visible
              ),
            ),
          ),
          // White curved background for details, overlaying the image
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: MediaQuery.of(context).size.height * 0.4, // Overlaps the bottom of the image
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20), // Adjusted top padding
              decoration: const BoxDecoration(
                color: Colors.white, // Explicitly white background for the details card
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.computerName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Available in stock quantity selector (new placement)
                        if (widget.status == 'Available')
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20, color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      if (_selectedQuantity > 1) {
                                        _selectedQuantity--;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  _selectedQuantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20, color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      if (_selectedQuantity < widget.stockQuantity) {
                                        _selectedQuantity++;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        else // If status is sold, just show "Out of stock"
                          Text(
                            'Out of stock',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8), // Adjusted spacing
                    Text(
                      'Entry Date: ${widget.entryDate}', // Entry Date moved here
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '\$${widget.price.toStringAsFixed(2)}', // Price moved here
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.descriptionPoints.map((point) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              Expanded(
                                child: Text(
                                  point,
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    // Status display (moved below description)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (widget.status == 'Sold' && widget.soldDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0), // Spacing below status badge
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sold Date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.soldDate!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24), // Final padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}