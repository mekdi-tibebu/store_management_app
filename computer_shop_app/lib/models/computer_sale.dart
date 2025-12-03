// lib/models/computer_sale.dart
// import 'package:flutter/foundation.dart';

// enum SaleStatus {
//   Available,
//   Sold,
//   Reserved,
// }

// extension SaleStatusExtension on SaleStatus {
//   String toDisplayString() {
//     switch (this) {
//       case SaleStatus.Available:
//         return 'Available';
//       case SaleStatus.Sold:
//         return 'Sold';
//       case SaleStatus.Reserved:
//         return 'Reserved';
//     }
//   }
// }

// class ComputerSale {
//   final String id;
//   final String model;
//   final String specs;
//   final double price;
//   SaleStatus status; // Can be mutable if you update it directly
//   DateTime? saleDate; // When it was sold

//   ComputerSale({
//     required this.id,
//     required this.model,
//     required this.specs,
//     required this.price,
//     this.status = SaleStatus.Available,
//     this.saleDate,
//   });

//   ComputerSale copyWith({
//     String? id,
//     String? model,
//     String? specs,
//     double? price,
//     SaleStatus? status,
//     DateTime? saleDate,
//   }) {
//     return ComputerSale(
//       id: id ?? this.id,
//       model: model ?? this.model,
//       specs: specs ?? this.specs,
//       price: price ?? this.price,
//       status: status ?? this.status,
//       saleDate: saleDate ?? this.saleDate,
//     );
//   }
// }

// @immutable // Good practice for classes with copyWith, implies fields are final
// class ComputerSale {
//   final String id;
//   final String model;
//   final String specs;
//   final double price;
//   final SaleStatus status; // Changed back to final
//   final DateTime? saleDate; // When it was sold (also final)

//   const ComputerSale({ // Use const constructor for immutable classes
//     required this.id,
//     required this.model,
//     required this.specs,
//     required this.price,
//     this.status = SaleStatus.Available,
//     this.saleDate,
//   });

//   ComputerSale copyWith({
//     String? id,
//     String? model,
//     String? specs,
//     double? price,
//     SaleStatus? status,
//     DateTime? saleDate,
//   }) {
//     return ComputerSale(
//       id: id ?? this.id,
//       model: model ?? this.model,
//       specs: specs ?? this.specs,
//       price: price ?? this.price,
//       status: status ?? this.status,
//       saleDate: saleDate ?? this.saleDate,
//     );
//   }
// }

// lib/models/computer_sale.dart







// import 'package:flutter/foundation.dart';

// enum SaleStatus {
//   Available,
//   Sold,
//   Reserved,
// }

// extension SaleStatusExtension on SaleStatus {




  
  //  String get value {
  //   switch (this) {
  //     case SaleStatus.Pending:
  //       return "Pending";
  //     case SaleStatus.Sold:
  //       return "Sold";
  //     case SaleStatus.Cancelled:
  //       return "Cancelled";
  //   }
  // }

  // String get value {
  //   switch (this) {
  //     case SaleStatus.Available:
  //       return 'Available';
  //     case SaleStatus.Sold:
  //       return 'Sold';
  //     case SaleStatus.Reserved:
  //       return 'Reserved';
  //   }
  // }






//   String toDisplayString() {
//     switch (this) {
//       case SaleStatus.Available:
//         return 'Available';
//       case SaleStatus.Sold:
//         return 'Sold';
//       case SaleStatus.Reserved:
//         return 'Reserved';
//     }
//   }

//   static SaleStatus fromString(String status) {
//     switch (status) {
//       case 'Available':
//         return SaleStatus.Available;
//       case 'Sold':
//         return SaleStatus.Sold;
//       case 'Reserved':
//         return SaleStatus.Reserved;
//       default:
//         throw Exception('Unknown sale status: $status');
//     }
//   }
// }

// @immutable
// class ComputerSale {
//   final String id;
//   final String model;
//   final String specs;
//   final double price;
//   final SaleStatus status;
//   final DateTime? saleDate;

//   const ComputerSale({
//     required this.id,
//     required this.model,
//     required this.specs,
//     required this.price,
//     this.status = SaleStatus.Available,
//     this.saleDate,
//   });







  // JSON → Dart object
  // factory ComputerSale.fromJson(Map<String, dynamic> json) {
  //   return ComputerSale(
  //     id: json['id'].toString(),
  //     model: json['model'],
  //     specs: json['specs'],
  //     price: double.tryParse(json['price'].toString()) ?? 0.0,
  //     status: SaleStatusExtension.fromString(json['status']),
  //     saleDate:
  //         json['sale_date'] != null ? DateTime.parse(json['sale_date']) : null,
  //   );
  // }

  // // Dart object → JSON
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'model': model,
  //     'specs': specs,
  //     'price': price,
  //     'status': status.toString().split('.').last,
  //     'sale_date': saleDate?.toIso8601String(),
  //   };
  // }


//   factory ComputerSale.fromJson(Map<String, dynamic> json) {
//     return ComputerSale(
//       id: json['id'].toString(),
//       model: json['model'],
//       specs: json['specs'],
//       price: double.parse(json['price'].toString()),
//       status: SaleStatus.values.firstWhere(
//         (e) => e.toString().split('.').last.toLowerCase() == json['status'].toLowerCase(),
//         orElse: () => SaleStatus.Available,
//       ),
//       saleDate: json['sale_date'] != null ? DateTime.parse(json['sale_date']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "model": model,
//       "specs": specs,
//       "price": price,
//       "status": status.toString().split('.').last,
//       "sale_date": saleDate?.toIso8601String(),
//     };
//   }

//   ComputerSale copyWith({
//     String? id,
//     String? model,
//     String? specs,
//     double? price,
//     SaleStatus? status,
//     DateTime? saleDate,
//   }) {
//     return ComputerSale(
//       id: id ?? this.id,
//       model: model ?? this.model,
//       specs: specs ?? this.specs,
//       price: price ?? this.price,
//       status: status ?? this.status,
//       saleDate: saleDate ?? this.saleDate,
//     );
//   }
// }








// enum SaleStatus { Available, Sold, Reserved }

// extension SaleStatusExtension on SaleStatus {
//   String toDisplayString() {
//     switch (this) {
//       case SaleStatus.Available:
//         return "Available";
//       case SaleStatus.Sold:
//         return "Sold";
//       case SaleStatus.Reserved:
//         return "Reserved";
//     }
//   }
// }

// enum SaleStatus { Available, Sold, Reserved }

// extension SaleStatusExtension on SaleStatus {
//   String toDisplayString() {
//     switch (this) {
//       case SaleStatus.Available:
//         return "Available";
//       case SaleStatus.Sold:
//         return "Sold";
//       case SaleStatus.Reserved:
//         return "Reserved";
//     }
//   }
// }

// class ComputerSale {
//   final String id;
//   final String name;
//   final double price;
//   final SaleStatus status;

//   ComputerSale({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.status,
//   });

//   factory ComputerSale.fromJson(Map<String, dynamic> json) => ComputerSale(
//         id: json['id'].toString(),
//         name: json['name'],
//         price: (json['price'] as num).toDouble(),
//         status: SaleStatus.values.firstWhere(
//             (e) => e.name == json['status'],
//             orElse: () => SaleStatus.Available),
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'price': price,
//         'status': status.name,
//       };
// }


// class ComputerSale {
//   final String id;
//   final String model;
//   final String specs;
//   final double price;
//   final SaleStatus status;
//   final DateTime? saleDate;

//   ComputerSale({
//     required this.id,
//     required this.model,
//     required this.specs,
//     required this.price,
//     required this.status,
//     this.saleDate,
//   });

//   factory ComputerSale.fromJson(Map<String, dynamic> json) {
//     return ComputerSale(
//       id: json['id'],
//       model: json['model'],
//       specs: json['specs'],
//       price: double.parse(json['price'].toString()),
//       status: SaleStatus.values.firstWhere(
//         (e) => e.name == json['status'],
//         orElse: () => SaleStatus.Available,
//       ),
//       saleDate: json['sale_date'] != null ? DateTime.parse(json['sale_date']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "model": model,
//       "specs": specs,
//       "price": price.toStringAsFixed(2),
//       "status": status.name,
//       "sale_date": saleDate?.toIso8601String(),
//     };
//   }
// }



enum SaleStatus { Available, Sold, Reserved }

extension SaleStatusExtension on SaleStatus {
  String toDisplayString() {
    switch (this) {
      case SaleStatus.Available:
        return "Available";
      case SaleStatus.Sold:
        return "Sold";
      case SaleStatus.Reserved:
        return "Reserved";
    }
  }
}

class ComputerSale {
  final String id;
  final String model; // matches your UI
  final String specs; // matches your UI
  final double price;
  final SaleStatus status;
  final DateTime? saleDate; // optional, for sold items

  ComputerSale({
    required this.id,
    required this.model,
    required this.specs,
    required this.price,
    required this.status,
    this.saleDate,
  });

  factory ComputerSale.fromJson(Map<String, dynamic> json) => ComputerSale(
        id: json['id'].toString(),
        model: json['model'],
        specs: json['specs'],
        // price: (json['price'] as num).toDouble(),
        price: double.tryParse(json['price'].toString()) ?? 0.0,
        status: SaleStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SaleStatus.Available,
        ),
        saleDate:
            json['sale_date'] != null ? DateTime.parse(json['sale_date']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'specs': specs,
        'price': price,
        'status': status.name,
        'sale_date': saleDate?.toIso8601String(),
      };
}
