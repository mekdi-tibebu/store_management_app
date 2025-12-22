enum ComputerStatus {
  available,
  sold,
  maintenance,
}

class Computer {
  final int? id;
  final String model;
  final String specs;
  final double price;
  final int quantity;
  final ComputerStatus status;
  final DateTime? saleDate;
  
  Computer({
    this.id,
    required this.model,
    required this.specs,
    required this.price,
    required this.quantity,
    this.status = ComputerStatus.available,
    this.saleDate,
  });
  
  factory Computer.fromJson(Map<String, dynamic> json) {
    return Computer(
      id: json['id'],
      model: json['model'] ?? '',
      specs: json['specs'] ?? '',
      price: (json['price'] is String) 
          ? double.tryParse(json['price']) ?? 0.0 
          : (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      status: _statusFromString(json['status']),
      saleDate: json['sale_date'] != null 
          ? DateTime.tryParse(json['sale_date']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'model': model,
      'specs': specs,
      'price': price,
      'quantity': quantity,
      'status': status.name,
      if (saleDate != null) 'sale_date': saleDate!.toIso8601String(),
    };
  }
  
  static ComputerStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'sold':
        return ComputerStatus.sold;
      case 'maintenance':
        return ComputerStatus.maintenance;
      default:
        return ComputerStatus.available;
    }
  }
  
  String get statusText {
    switch (status) {
      case ComputerStatus.available:
        return 'Available';
      case ComputerStatus.sold:
        return 'Sold';
      case ComputerStatus.maintenance:
        return 'Maintenance';
    }
  }
}
