import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final SalesService _salesService = SalesService();
  
  List<Sale> _sales = [];
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};

  List<Sale> get sales => _sales;
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get stats => _stats;

  SalesProvider() {
    _salesService.getUserSales().listen((sales) {
      _sales = sales;
      notifyListeners();
    });
    _salesService.getCustomers().listen((customers) {
      _customers = customers;
      notifyListeners();
    });
    loadStats();
  }

  Future<void> loadStats() async {
    _stats = await _salesService.getSalesStats();
    notifyListeners();
  }

  Future<bool> createSale(Sale sale) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _salesService.createSale(sale);
      await loadStats();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelSale(String saleId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _salesService.cancelSale(saleId);
      await loadStats();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _salesService.addCustomer(customer);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
 
  Future<Map<String, dynamic>> getReportData(String period) async {
    final user = _auth.currentUser;
    if (user == null) return {'revenue': 0.0, 'costs': 0.0, 'profit': 0.0, 'salesList': []};

    DateTime now = DateTime.now();
    DateTime startDate;

    if (period == 'Daily') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (period == 'Weekly') {
      startDate = now.subtract(const Duration(days: 7));
    } else {
      startDate = DateTime(now.year, now.month, 1);
    }

    try {
      final snapshot = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      double totalRevenue = 0;
      double totalCosts = 0;
      List<Sale> salesList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // 1. Calculate Revenue
        double docRev = (data['total'] ?? 0).toDouble();
        
        // 2. Calculate Cost (Fallback logic included)
        double docCost = 0;
        if (data.containsKey('totalCost') && data['totalCost'] != 0) {
          docCost = (data['totalCost'] ?? 0).toDouble();
        } else if (data.containsKey('items')) {
          // If the top-level totalCost is missing, sum the items
          List items = data['items'] as List;
          for (var item in items) {
            double cPrice = (item['costPrice'] ?? 0).toDouble();
            int qty = (item['quantity'] ?? 1).toInt();
            docCost += (cPrice * qty);
          }
        }

        totalRevenue += docRev;
        totalCosts += docCost;
        
        // 3. Build the list for PDF Export
        salesList.add(Sale.fromJson(data, doc.id));
      }

      return {
        'revenue': totalRevenue,
        'costs': totalCosts,
        'profit': totalRevenue - totalCosts,
        'salesList': salesList,
      };
    } catch (e) {
      print("REPORT ERROR: $e");
      return {'revenue': 0.0, 'costs': 0.0, 'profit': 0.0, 'salesList': []};
    }
  }
  String generateSaleNumber() {
    return _salesService.generateSaleNumber();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
