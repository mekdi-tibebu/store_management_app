import 'package:cloud_firestore/cloud_firestore.dart';

class Computer {
  final String? id;
  final String userId;
  final String name;
  final String category;
  final String brand;
  final String processor;
  final String ram;
  final String storage;
  final String gpu;
  final double price;
  final int quantity;
  final List<String> serialNumbers;
  final String description;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double costPrice;
  final String? imageBase64; 

  Computer({
    this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.brand,
    required this.processor,
    required this.ram,
    required this.storage,
    this.gpu = '',
    required this.price,
    required this.costPrice,
    required this.quantity,
    this.serialNumbers = const [],
    this.description = '',
    this.imageUrl,
    this.status = 'available',
    required this.createdAt,
    required this.updatedAt,
    this.imageBase64,
  });

  factory Computer.fromJson(Map<String, dynamic> json, String id) {
    return Computer(
      id: id,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      processor: json['processor'] ?? '',
      ram: json['ram'] ?? '',
      storage: json['storage'] ?? '',
      gpu: json['gpu'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      serialNumbers: List<String>.from(json['serialNumbers'] ?? []),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'available',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageBase64: json['imageBase64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'brand': brand,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'gpu': gpu,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'serialNumbers': serialNumbers,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageBase64': imageBase64,
    };
  }

  // FIXED: Added imageBase64 to copyWith
  Computer copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? brand,
    String? processor,
    String? ram,
    String? storage,
    String? gpu,
    double? price,
    double? costPrice,
    int? quantity,
    List<String>? serialNumbers,
    String? description,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageBase64, // ADDED
  }) {
    return Computer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      processor: processor ?? this.processor,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      gpu: gpu ?? this.gpu,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      serialNumbers: serialNumbers ?? this.serialNumbers,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageBase64: imageBase64 ?? this.imageBase64, // ADDED
    );
  }
}