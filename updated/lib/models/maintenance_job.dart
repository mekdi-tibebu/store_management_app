enum MaintenanceStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

class MaintenanceJob {
  final int? id;
  final String customerName;
  final String computerModel;
  final String reportedIssue;
  final String? notes;
  final MaintenanceStatus status;
  final DateTime dateReported;
  final DateTime? dateCompleted;
  
  MaintenanceJob({
    this.id,
    required this.customerName,
    required this.computerModel,
    required this.reportedIssue,
    this.notes,
    this.status = MaintenanceStatus.pending,
    required this.dateReported,
    this.dateCompleted,
  });
  
  factory MaintenanceJob.fromJson(Map<String, dynamic> json) {
    return MaintenanceJob(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      computerModel: json['computer_model'] ?? '',
      reportedIssue: json['reported_issue'] ?? '',
      notes: json['notes'],
      status: _statusFromString(json['status']),
      dateReported: DateTime.tryParse(json['date_reported'] ?? '') ?? DateTime.now(),
      dateCompleted: json['date_completed'] != null
          ? DateTime.tryParse(json['date_completed'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer_name': customerName,
      'computer_model': computerModel,
      'reported_issue': reportedIssue,
      if (notes != null) 'notes': notes,
      'status': _statusToString(status),
      'date_reported': dateReported.toIso8601String(),
      if (dateCompleted != null) 'date_completed': dateCompleted!.toIso8601String(),
    };
  }
  
  static MaintenanceStatus _statusFromString(String? status) {
    final normalized = status?.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    switch (normalized) {
      case 'inprogress':
        return MaintenanceStatus.inProgress;
      case 'completed':
        return MaintenanceStatus.completed;
      case 'cancelled':
        return MaintenanceStatus.cancelled;
      case 'pending':
      default:
        return MaintenanceStatus.pending;
    }
  }
  
  static String _statusToString(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.inProgress:
        return 'InProgress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  String get statusText {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }
}
