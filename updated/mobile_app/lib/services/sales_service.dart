import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale_model.dart';
import '../models/computer_model.dart';
import 'inventory_service.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all sales for current user
  Stream<List<Sale>> getUserSales() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('sales')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Sale.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single sale by ID
  Future<Sale?> getSale(String saleId) async {
    try {
      final doc = await _firestore.collection('sales').doc(saleId).get();
      if (!doc.exists) return null;
      return Sale.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw 'Failed to load sale: $e';
    }
  }

  // Create new sale
  Future<String> createSale(Sale sale) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }
      double totalCost = sale.items.fold(0, (sum, item) => sum + (item.costPrice * item.quantity));
      double profit = sale.total - totalCost;
      // Start a batch write to update inventory and create sale atomically
      final batch = _firestore.batch();
      final saleRef = _firestore.collection('sales').doc();

      // Create sale document
      final saleData = Sale(
        userId: userId,
        saleNumber: sale.saleNumber,
        customerId: sale.customerId,
        customerName: sale.customerName,
        customerPhone: sale.customerPhone,
        items: sale.items,
        subtotal: sale.subtotal,
        tax: sale.tax,
        total: sale.total,
        totalCost: totalCost,
        profit: profit,
        paymentMethod: sale.paymentMethod,
        status: sale.status,
        createdAt: sale.createdAt,
      );
      batch.set(saleRef, saleData.toJson());

      // Update inventory quantities
      for (final item in sale.items) {
        final computerDoc = await _firestore.collection('computers').doc(item.computerId).get();
        if (computerDoc.exists) {
          final computer = Computer.fromJson(computerDoc.data()!, computerDoc.id);
          final newQuantity = computer.quantity - item.quantity;
          
          if (newQuantity < 0) {
            throw 'Insufficient stock for ${computer.name}';
          }

          batch.update(computerDoc.reference, {
            'quantity': newQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Commit the batch
      await batch.commit();
      return saleRef.id;
    } catch (e) {
      throw 'Failed to create sale: $e';
    }
  }

  // Cancel sale (and restore inventory)
  Future<void> cancelSale(String saleId) async {
    try {
      final sale = await getSale(saleId);
      if (sale == null) {
        throw 'Sale not found';
      }

      if (sale.status == 'cancelled') {
        throw 'Sale already cancelled';
      }

      // Start a batch write
      final batch = _firestore.batch();

      // Update sale status
      final saleRef = _firestore.collection('sales').doc(saleId);
      batch.update(saleRef, {'status': 'cancelled'});

      // Restore inventory quantities
      for (final item in sale.items) {
        final computerDoc = await _firestore.collection('computers').doc(item.computerId).get();
        if (computerDoc.exists) {
          final computer = Computer.fromJson(computerDoc.data()!, computerDoc.id);
          final newQuantity = computer.quantity + item.quantity;

          batch.update(computerDoc.reference, {
            'quantity': newQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to cancel sale: $e';
    }
  }

  // Get sales by date range
  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Sale.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to load sales: $e';
    }
  }

  // Get sales statistics
  Future<Map<String, dynamic>> getSalesStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      Query query = _firestore
          .collection('sales')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed');

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final sales = snapshot.docs
          .map((doc) => Sale.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      int totalSales = sales.length;
      double totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.total);
      int totalItemsSold = sales.fold(0, (sum, sale) => sum + sale.totalItems);
      double averageSale = totalSales > 0 ? totalRevenue / totalSales : 0;

      return {
        'totalSales': totalSales,
        'totalRevenue': totalRevenue,
        'totalItemsSold': totalItemsSold,
        'averageSale': averageSale,
      };
    } catch (e) {
      return {};
    }
  }

  // Get best selling products
  Future<List<Map<String, dynamic>>> getBestSellingProducts({int limit = 10}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      final sales = snapshot.docs
          .map((doc) => Sale.fromJson(doc.data(), doc.id))
          .toList();

      // Aggregate by product
      Map<String, Map<String, dynamic>> productStats = {};
      
      for (final sale in sales) {
        for (final item in sale.items) {
          if (!productStats.containsKey(item.computerId)) {
            productStats[item.computerId] = {
              'computerId': item.computerId,
              'computerName': item.computerName,
              'quantitySold': 0,
              'revenue': 0.0,
            };
          }
          productStats[item.computerId]!['quantitySold'] += item.quantity;
          productStats[item.computerId]!['revenue'] += item.totalPrice;
        }
      }

      // Sort by quantity sold and return top items
      final sortedProducts = productStats.values.toList()
        ..sort((a, b) => (b['quantitySold'] as int).compareTo(a['quantitySold'] as int));

      return sortedProducts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Generate sale number
  String generateSaleNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SALE-${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  // Get all customers
  Stream<List<Customer>> getCustomers() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('customers')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Customer.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Add customer
  Future<String> addCustomer(Customer customer) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final customerData = Customer(
        userId: userId,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final doc = await _firestore.collection('customers').add(customerData.toJson());
      return doc.id;
    } catch (e) {
      throw 'Failed to add customer: $e';
    }
  }

  // Update customer
  Future<void> updateCustomer(String customerId, Customer customer) async {
    try {
      await _firestore.collection('customers').doc(customerId).update({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update customer: $e';
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
    } catch (e) {
      throw 'Failed to delete customer: $e';
    }
  }
}
