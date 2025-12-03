// // Add this import for Color and Colors
// import 'package:flutter/material.dart';

// // lib/models/maintenance_job.dart
// enum MaintenanceStatus {
//   Pending,
//   InProgress,
//   Completed,
//   Cancelled,
// }

// extension MaintenanceStatusExtension on MaintenanceStatus {
//   String toDisplayString() {
//     switch (this) {
//       case MaintenanceStatus.Pending:
//         return 'Pending';
//       case MaintenanceStatus.InProgress:
//         return 'In Progress';
//       case MaintenanceStatus.Completed:
//         return 'Completed';
//       case MaintenanceStatus.Cancelled:
//         return 'Cancelled';
//     }
//   }
// }

// class MaintenanceJob {
//   final String id;
//   final String customerName;
//   final String computerModel;
//   final String reportedIssue;
//   final DateTime dateReported;
//   final MaintenanceStatus status;
//   String? notes; // Optional notes
//   DateTime? dateCompleted; // Optional completion date

//   MaintenanceJob({
//     required this.id,
//     required this.customerName,
//     required this.computerModel,
//     required this.reportedIssue,
//     required this.dateReported,
//     required this.status,
//     this.notes,
//     this.dateCompleted,
//   });

//   // You might want to add a copyWith method for immutability
//   MaintenanceJob copyWith({
//     String? id,
//     String? customerName,
//     String? computerModel,
//     String? reportedIssue,
//     DateTime? dateReported,
//     MaintenanceStatus? status,
//     String? notes,
//     DateTime? dateCompleted,
//   }) {
//     return MaintenanceJob(
//       id: id ?? this.id,
//       customerName: customerName ?? this.customerName,
//       computerModel: computerModel ?? this.computerModel,
//       reportedIssue: reportedIssue ?? this.reportedIssue,
//       dateReported: dateReported ?? this.dateReported,
//       status: status ?? this.status,
//       notes: notes ?? this.notes,
//       dateCompleted: dateCompleted ?? this.dateCompleted,
//     );
//   }
// }

// lib/models/maintenance_job.dart
// import 'package:flutter/material.dart';

// enum MaintenanceStatus {
//   Pending,
//   InProgress,
//   Completed,
//   Cancelled,
// }

// extension MaintenanceStatusExtension on MaintenanceStatus {
//   String toDisplayString() {
//     switch (this) {
//       case MaintenanceStatus.Pending:
//         return 'Pending';
//       case MaintenanceStatus.InProgress:
//         return 'In Progress';
//       case MaintenanceStatus.Completed:
//         return 'Completed';
//       case MaintenanceStatus.Cancelled:
//         return 'Cancelled';
//     }
//   }

//   static MaintenanceStatus fromString(String status) {
//     switch (status) {
//       case 'Pending':
//         return MaintenanceStatus.Pending;
//       case 'InProgress':
//         return MaintenanceStatus.InProgress;
//       case 'Completed':
//         return MaintenanceStatus.Completed;
//       case 'Cancelled':
//         return MaintenanceStatus.Cancelled;
//       default:
//         throw Exception('Unknown status: $status');
//     }
//   }
// }

// class MaintenanceJob {
//   final String id;
//   final String customerName;
//   final String computerModel;
//   final String reportedIssue;
//   final DateTime dateReported;
//   final MaintenanceStatus status;
//   final String? notes;
//   final DateTime? dateCompleted;

//   MaintenanceJob({
//     required this.id,
//     required this.customerName,
//     required this.computerModel,
//     required this.reportedIssue,
//     required this.dateReported,
//     required this.status,
//     this.notes,
//     this.dateCompleted,
//   });

//   // Factory for converting JSON → Dart object
//   factory MaintenanceJob.fromJson(Map<String, dynamic> json) {
//     return MaintenanceJob(
//       id: json['id'].toString(),
//       customerName: json['customer_name'],
//       computerModel: json['computer_model'],
//       reportedIssue: json['reported_issue'],
//       dateReported: DateTime.parse(json['date_reported']),
//       status: MaintenanceStatusExtension.fromString(json['status']),
//       notes: json['notes'],
//       dateCompleted: json['date_completed'] != null
//           ? DateTime.parse(json['date_completed'])
//           : null,
//     );
//   }

//   // Method for converting Dart object → JSON (for POST/PUT/PATCH)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'customer_name': customerName,
//       'computer_model': computerModel,
//       'reported_issue': reportedIssue,
//       'date_reported': dateReported.toIso8601String(),
//       'status': status.toString().split('.').last,
//       'notes': notes,
//       'date_completed': dateCompleted?.toIso8601String(),
//     };
//   }

//   MaintenanceJob copyWith({
//     String? id,
//     String? customerName,
//     String? computerModel,
//     String? reportedIssue,
//     DateTime? dateReported,
//     MaintenanceStatus? status,
//     String? notes,
//     DateTime? dateCompleted,
//   }) {
//     return MaintenanceJob(
//       id: id ?? this.id,
//       customerName: customerName ?? this.customerName,
//       computerModel: computerModel ?? this.computerModel,
//       reportedIssue: reportedIssue ?? this.reportedIssue,
//       dateReported: dateReported ?? this.dateReported,
//       status: status ?? this.status,
//       notes: notes ?? this.notes,
//       dateCompleted: dateCompleted ?? this.dateCompleted,
//     );
//   }
// }





// lib/models/maintenance_job.dart
// import 'package:flutter/material.dart';

// enum MaintenanceStatus {
//   Pending,
//   InProgress,
//   Completed,
//   Cancelled,
// }

// extension MaintenanceStatusExtension on MaintenanceStatus {





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
//       case MaintenanceStatus.Pending:
//         return 'Pending';
//       case MaintenanceStatus.InProgress:
//         return 'In Progress';
//       case MaintenanceStatus.Completed:
//         return 'Completed';
//       case MaintenanceStatus.Cancelled:
//         return 'Cancelled';
//     }
//   }

//   static MaintenanceStatus fromString(String status) {
//     switch (status) {
//       case 'Pending':
//         return MaintenanceStatus.Pending;
//       case 'InProgress':
//         return MaintenanceStatus.InProgress;
//       case 'Completed':
//         return MaintenanceStatus.Completed;
//       case 'Cancelled':
//         return MaintenanceStatus.Cancelled;
//       default:
//         throw Exception('Unknown status: $status');
//     }
//   }

//   String toJsonValue() {
//     // Sends enum as string without prefix
//     return toString().split('.').last;
//   }
// }

// class MaintenanceJob {
//   final String id;
//   final String customerName;
//   final String computerModel;
//   final String reportedIssue;
//   final DateTime dateReported;
//   final MaintenanceStatus status;
//   final String? notes;
//   final DateTime? dateCompleted;

//   MaintenanceJob({
//     required this.id,
//     required this.customerName,
//     required this.computerModel,
//     required this.reportedIssue,
//     required this.dateReported,
//     required this.status,
//     this.notes,
//     this.dateCompleted,
//   });

//   /// Factory for converting JSON → Dart object
//   factory MaintenanceJob.fromJson(Map<String, dynamic> json) {
//     return MaintenanceJob(
//       id: json['id'].toString(),
//       customerName: json['customer_name'] ?? '',
//       computerModel: json['computer_model'] ?? '',
//       reportedIssue: json['reported_issue'] ?? '',
//       dateReported: DateTime.parse(json['date_reported']),
//       status: MaintenanceStatusExtension.fromString(json['status']),
//       notes: json['notes'],
//       dateCompleted: json['date_completed'] != null
//           ? DateTime.tryParse(json['date_completed'])
//           : null,
//     );
//   }

//   /// Method for converting Dart object → JSON (for POST/PUT/PATCH)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'customer_name': customerName,
//       'computer_model': computerModel,
//       'reported_issue': reportedIssue,
//       'date_reported': dateReported.toIso8601String(),
//       'status': status.toJsonValue(),
//       'notes': notes,
//       'date_completed': dateCompleted?.toIso8601String(),
//     };
//   }

//   /// copyWith for immutability
//   MaintenanceJob copyWith({
//     String? id,
//     String? customerName,
//     String? computerModel,
//     String? reportedIssue,
//     DateTime? dateReported,
//     MaintenanceStatus? status,
//     String? notes,
//     DateTime? dateCompleted,
//   }) {
//     return MaintenanceJob(
//       id: id ?? this.id,
//       customerName: customerName ?? this.customerName,
//       computerModel: computerModel ?? this.computerModel,
//       reportedIssue: reportedIssue ?? this.reportedIssue,
//       dateReported: dateReported ?? this.dateReported,
//       status: status ?? this.status,
//       notes: notes ?? this.notes,
//       dateCompleted: dateCompleted ?? this.dateCompleted,
//     );
//   }
// }





// enum MaintenanceStatus { Pending, InProgress, Completed, Cancelled }

// extension MaintenanceStatusExtension on MaintenanceStatus {
//   String toDisplayString() {
//     switch (this) {
//       case MaintenanceStatus.Pending:
//         return 'Pending';
//       case MaintenanceStatus.InProgress:
//         return 'In Progress';
//       case MaintenanceStatus.Completed:
//         return 'Completed';
//       case MaintenanceStatus.Cancelled:
//         return 'Cancelled';
//     }
//   }
// }





// class MaintenanceJob {
//   final String id;
//   final String customerName;
//   final String computerModel;
//   final String reportedIssue;
//   final DateTime dateReported; // Add this
//   final MaintenanceStatus status;
//   final String? notes;
//   final DateTime? dateCompleted;

//   MaintenanceJob({
//     required this.id,
//     required this.customerName,
//     required this.computerModel,
//     required this.reportedIssue,
//     required this.dateReported, // Required in constructor
//     required this.status,
//     this.notes,
//     this.dateCompleted,
//   });

//   factory MaintenanceJob.fromJson(Map<String, dynamic> json) {
//     return MaintenanceJob(
//       id: json['id'],
//       customerName: json['customer_name'],
//       computerModel: json['computer_model'],
//       reportedIssue: json['reported_issue'],
//       dateReported: DateTime.parse(json['date_reported']), // parse date
//       status: MaintenanceStatus.values.firstWhere(
//         (e) => e.name == json['status'],
//         orElse: () => MaintenanceStatus.Pending,
//       ),
//       notes: json['notes'],
//       dateCompleted: json['date_completed'] != null ? DateTime.parse(json['date_completed']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "customer_name": customerName,
//       "computer_model": computerModel,
//       "reported_issue": reportedIssue,
//       "date_reported": dateReported.toIso8601String(),
//       "status": status.name,
//       "notes": notes,
//       "date_completed": dateCompleted?.toIso8601String(),
//     };
//   }

//    MaintenanceJob copyWith({
//     String? id,
//     String? customerName,
//     String? computerModel,
//     String? reportedIssue,
//     DateTime? dateReported,
//     MaintenanceStatus? status,
//     String? notes,
//     DateTime? dateCompleted,
//   }) {
//     return MaintenanceJob(
//       id: id ?? this.id,
//       customerName: customerName ?? this.customerName,
//       computerModel: computerModel ?? this.computerModel,
//       reportedIssue: reportedIssue ?? this.reportedIssue,
//       dateReported: dateReported ?? this.dateReported,
//       status: status ?? this.status,
//       notes: notes ?? this.notes,
//       dateCompleted: dateCompleted ?? this.dateCompleted,
//     );
//   }
// }




// class MaintenanceJob {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime dateReported;
//   final MaintenanceStatus status;

//   MaintenanceJob({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.dateReported,
//     required this.status,
//   });

//   MaintenanceJob copyWith({
//     String? id,
//     String? title,
//     String? description,
//     DateTime? dateReported,
//     MaintenanceStatus? status,
//   }) {
//     return MaintenanceJob(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       dateReported: dateReported ?? this.dateReported,
//       status: status ?? this.status,
//     );
//   }

//   factory MaintenanceJob.fromJson(Map<String, dynamic> json) => MaintenanceJob(
//         id: json['id'].toString(),
//         title: json['title'],
//         description: json['description'],
//         dateReported: DateTime.parse(json['date_reported']),
//         status: MaintenanceStatus.values.firstWhere(
//             (e) => e.name == json['status'],
//             orElse: () => MaintenanceStatus.Pending),
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'description': description,
//         'date_reported': dateReported.toIso8601String(),
//         'status': status.name,
//       };
// }


// enum MaintenanceStatus { Pending, InProgress, Completed }

// extension MaintenanceStatusExtension on MaintenanceStatus {
//   String toDisplayString() {
//     switch (this) {
//       case MaintenanceStatus.Pending:
//         return 'Pending';
//       case MaintenanceStatus.InProgress:
//         return 'In Progress';
//       case MaintenanceStatus.Completed:
//         return 'Completed';
//       case MaintenanceStatus.Cancelled:
//         return 'Cancelled';
//     }
//   }
// }

// class MaintenanceJob {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime dateReported; // required by UI
//   final MaintenanceStatus status;

//   MaintenanceJob({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.dateReported,
//     required this.status,
//   });

//   // Allows updating fields like copyWith
//   MaintenanceJob copyWith({
//     String? id,
//     String? title,
//     String? description,
//     DateTime? dateReported,
//     MaintenanceStatus? status,
//   }) {
//     return MaintenanceJob(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       dateReported: dateReported ?? this.dateReported,
//       status: status ?? this.status,
//     );
//   }

//   factory MaintenanceJob.fromJson(Map<String, dynamic> json) => MaintenanceJob(
//         id: json['id'].toString(),
//         title: json['title'],
//         description: json['description'],
//         dateReported: DateTime.parse(json['date_reported']),
//         status: MaintenanceStatus.values.firstWhere(
//           (e) => e.name == json['status'],
//           orElse: () => MaintenanceStatus.Pending,
//         ),
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'description': description,
//         'date_reported': dateReported.toIso8601String(),
//         'status': status.name,
//       };
// }




// lib/models/maintenance_job.dart
enum MaintenanceStatus { Pending, InProgress, Completed, Cancelled }

extension MaintenanceStatusExtension on MaintenanceStatus {
  String toDisplayString() {
    switch (this) {
      case MaintenanceStatus.Pending:
        return "Pending";
      case MaintenanceStatus.InProgress:
        return "In Progress";
      case MaintenanceStatus.Completed:
        return "Completed";
      case MaintenanceStatus.Cancelled:
        return "Cancelled";
    }
  }
}

class MaintenanceJob {
  // final int id;
  final int? id;
  final String customerName;
  final String computerModel;
  final String reportedIssue;
  final DateTime dateReported;
  final DateTime? dateCompleted;
  final String? notes;
  final MaintenanceStatus status;

  MaintenanceJob({
    required this.id,
    required this.customerName,
    required this.computerModel,
    required this.reportedIssue,
    required this.dateReported,
    this.dateCompleted,
    this.notes,
    required this.status,
  });

  /// ✅ Add copyWith so detail screen can update the status
  MaintenanceJob copyWith({
    // String? id,
    int? id,
    String? customerName,
    String? computerModel,
    String? reportedIssue,
    DateTime? dateReported,
    DateTime? dateCompleted,
    String? notes,
    MaintenanceStatus? status,
  }) {
    return MaintenanceJob(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      computerModel: computerModel ?? this.computerModel,
      reportedIssue: reportedIssue ?? this.reportedIssue,
      dateReported: dateReported ?? this.dateReported,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  /// Example JSON parser (if fetching from Django backend)
  factory MaintenanceJob.fromJson(Map<String, dynamic> json) {
    return MaintenanceJob(
      // id: json['id'],
      // id: int.tryParse(json['id'].toString()) ?? 0,
      // id: json['id'] as String?,
      // id: json['id'] as int?,
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()),
      customerName: json['customer_name'],
      computerModel: json['computer_model'],
      reportedIssue: json['reported_issue'],
      dateReported: DateTime.parse(json['date_reported']),
      dateCompleted: json['date_completed'] != null
          ? DateTime.parse(json['date_completed'])
          : null,
      notes: json['notes'],
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MaintenanceStatus.Pending,
      ),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'customer_name': customerName,
  //     'computer_model': computerModel,
  //     'reported_issue': reportedIssue,
  //     'date_reported': dateReported.toIso8601String(),
  //     'date_completed': dateCompleted?.toIso8601String(),
  //     'notes': notes,
  //     'status': status.toString().split('.').last,
  //   };
  // }


  Map<String, dynamic> toJson({bool includeId = true}) {
  final data = {
    'id': id,
    'customer_name': customerName,
    'computer_model': computerModel,
    'reported_issue': reportedIssue,
    'date_reported': dateReported.toIso8601String(),
    'date_completed': dateCompleted?.toIso8601String(),
    'notes': notes,
    'status': status.toString().split('.').last,
  };

  // Only include 'id' if explicitly requested AND it's not null
  if (includeId && id != null) {
    data['id'] = id;
  }

  return data;
}

}
