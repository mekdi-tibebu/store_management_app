import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../services/report_export_service.dart';
import '../../models/sale_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light professional background
      appBar: AppBar(
        title: const Text('Financial Analytics', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Styled Period Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: Colors.indigo,
                selectedForegroundColor: Colors.white,
                side: BorderSide(color: Colors.indigo.shade100),
              ),
              segments: const [
                ButtonSegment(value: 'Daily', label: Text('Daily'), icon: Icon(Icons.today_rounded)),
                ButtonSegment(value: 'Weekly', label: Text('Weekly'), icon: Icon(Icons.view_week_rounded)),
                ButtonSegment(value: 'Monthly', label: Text('Monthly'), icon: Icon(Icons.calendar_month_rounded)),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedPeriod = newSelection.first);
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: salesProvider.getReportData(_selectedPeriod),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final data = snapshot.data ?? <String, dynamic>{
                  'revenue': 0.0, 
                  'costs': 0.0, 
                  'profit': 0.0, 
                  'salesList': <Sale>[]
                };
                
                // final double revenue = data['revenue'];
                // final double profit = data['profit'];
                // final double costs = data['costs'];
                // final List<Sale> itemsSoldInPeriod = List<Sale>.from(data['salesList'] ?? []);
                                // FIX 1: Safe Double Casting (Prevents 0.00 issue)
                final double revenue = (data['revenue'] ?? 0.0).toDouble();
                final double costs = (data['costs'] ?? 0.0).toDouble();
                final double profit = (data['profit'] ?? 0.0).toDouble();

                // FIX 2: Correct List Casting
                final List<Sale> itemsSoldInPeriod = List<Sale>.from(data['salesList'] ?? []);
                if (revenue == 0 && profit == 0) {
                  return _buildEmptyState();
                }

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Main Profit Card with Gradient
                    _buildMainGradientCard(profit, currencyFormat),
                    
                    const SizedBox(height: 24),
                    
                    // Detail Cards Grid
                    Row(
                      children: [
                        Expanded(child: _buildValueCard("Total Revenue", revenue, Icons.trending_up, Colors.green)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildValueCard("Total Costs", costs, Icons.trending_down, Colors.orange)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Detailed Breakdown Section
                    const Text("Summary Breakdown", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(revenue, costs, profit, currencyFormat),
                    
                    const SizedBox(height: 32),
                    
                    // Export Section
                    const Text("Export Professional Report", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 12),
                    _buildExportSection(revenue, costs, profit, itemsSoldInPeriod),
                    
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "Report generated on ${DateFormat('MMM dd, yyyy | HH:mm').format(DateTime.now())}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: ERROR STATE ---
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[300], size: 60),
          const SizedBox(height: 16),
          Text("Something went wrong", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
          Text(error, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // --- UI COMPONENT: EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/5058/5058046.png', // Placeholder for empty data
            height: 120,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),
          const SizedBox(height: 20),
          Text("No transactions found", 
            style: TextStyle(color: Colors.blueGrey[300], fontSize: 18, fontWeight: FontWeight.w500)),
          Text("Try changing the period or check back later", 
            style: TextStyle(color: Colors.blueGrey[200])),
        ],
      ),
    );
  }

  // --- UI COMPONENT: FANCY GRADIENT CARD ---
  Widget _buildMainGradientCard(double profit, NumberFormat format) {
    final isProfit = profit >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit 
            ? [Colors.indigo.shade800, Colors.indigo.shade500] 
            : [Colors.red.shade800, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.indigo : Colors.red).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("NET PROFIT - $_selectedPeriod", 
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              const Icon(Icons.auto_graph_rounded, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 12),
          Text(format.format(profit), 
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: Text(isProfit ? "Growth is steady" : "Loss detected", 
              style: const TextStyle(color: Colors.white, fontSize: 10)),
          )
        ],
      ),
    );
  }

  // --- UI COMPONENT: MINI VALUE CARDS ---
  Widget _buildValueCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(NumberFormat.compactSimpleCurrency(name: 'ETB ').format(amount), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENT: BREAKDOWN CARD ---
  Widget _buildBreakdownCard(double rev, double cost, double profit, NumberFormat format) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildBreakdownRow("Gross Revenue", rev, Colors.green),
          Divider(height: 1, color: Colors.grey[50]),
          _buildBreakdownRow("Operational Costs", -cost, Colors.red),
          Divider(height: 1, color: Colors.grey[50]),
          _buildBreakdownRow("Net Profit", profit, Colors.indigo, isLast: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, Color color, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey)),
          Text(NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2).format(amount), 
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- UI COMPONENT: EXPORT BUTTONS ---
  Widget _buildExportSection(double rev, double cost, double profit, List<Sale> items) {
    return Row(
      children: [
        Expanded(
          child: _buildExportButton(
            "PDF Report", 
            Icons.picture_as_pdf_rounded, 
            Colors.red.shade700, 
            () => ReportExportService.exportToPdf(
              period: _selectedPeriod, revenue: rev, costs: cost, profit: profit, items: items
            )
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildExportButton(
            "Excel Sheet", 
            Icons.table_chart_rounded, 
            Colors.green.shade700, 
            () => ReportExportService.exportToExcel(
              period: _selectedPeriod, revenue: rev, costs: cost, profit: profit, items: items
            )
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}