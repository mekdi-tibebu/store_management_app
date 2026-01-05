import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json, String id) {
    return Customer(
      id: id,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class SaleItem {
  final String computerId;
  final String computerName;
  final int quantity;
  final double unitPrice;
  final double costPrice; // NEW: Buying price from Computer model
  final double totalPrice;

  SaleItem({
    required this.computerId,
    required this.computerName,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice, // Required for P&L logic
    required this.totalPrice,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      computerId: json['computerId'] ?? '',
      computerName: json['computerName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(), // NEW
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'computerId': computerId,
      'computerName': computerName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'costPrice': costPrice, // NEW
      'totalPrice': totalPrice,
    };
  }
}

class Sale {
  final String? id;
  final String userId;
  final String saleNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<SaleItem> items;
  final double subtotal;
  final double tax;
  final double total;      // This is Revenue
  final double totalCost;  // NEW: Sum of all item costPrices
  final double profit;     // NEW: total - totalCost
  final String paymentMethod;
  final String status; 
  final DateTime createdAt;

  Sale({
    this.id,
    required this.userId,
    required this.saleNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    this.tax = 0,
    required this.total,
    required this.totalCost, // NEW
    required this.profit,    // NEW
    required this.paymentMethod,
    this.status = 'completed',
    required this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json, String id) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Sale(
      id: id,
      userId: json['userId'] ?? '',
      saleNumber: json['saleNumber'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      items: itemsList,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      totalCost: (json['totalCost'] ?? 0).toDouble(), // NEW
      profit: (json['profit'] ?? 0).toDouble(),       // NEW
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'completed',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'saleNumber': saleNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'totalCost': totalCost, // NEW: Saves total cost to DB
      'profit': profit,       // NEW: Saves profit to DB
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}