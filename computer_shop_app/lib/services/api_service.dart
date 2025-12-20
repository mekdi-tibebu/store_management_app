import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/computer_sale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:computer_shop_app/services/auth_service.dart';
import '../models/maintenance_job.dart';

class ApiService {
  final String baseUrl = "https://computer-shop-backend-4uyg.onrender.com/api";
  final http.Client client = http.Client();


  Future<List<MaintenanceJob>> getMaintenanceJobs() async {
    final response = await client.get(Uri.parse("$baseUrl/maintenance-jobs/"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((job) => MaintenanceJob.fromJson(job)).toList();
    } else {
      throw Exception("Failed to load maintenance jobs: ${response.body}");
    }
  }

  Future<MaintenanceJob> addMaintenanceJob(MaintenanceJob job) async {
    final response = await client.post(
      Uri.parse("$baseUrl/maintenance-jobs/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(job.toJson(includeId: false)),
    );
    if (response.statusCode == 201) {
      return MaintenanceJob.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to add maintenance job: ${response.body}");
    }
  }

  Future<MaintenanceJob> updateMaintenanceJob(MaintenanceJob job) async {
    final response = await client.put(
      Uri.parse("$baseUrl/maintenance-jobs/${job.id}/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(job.toJson(includeId: true)),
    );
    if (response.statusCode == 200) {
      return MaintenanceJob.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update maintenance job: ${response.body}");
    }
  }

  Future<void> updateMaintenanceJobStatus(int id, String status) async {
    final response = await client.patch(
      Uri.parse("$baseUrl/maintenance-jobs/$id/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 404) {
      throw Exception('Job with ID $id not found.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to update maintenance job status: ${response.body}');
    }
  }

  Future<void> deleteMaintenanceJob(String jobId) async {
    final response = await client.delete(Uri.parse("$baseUrl/maintenance-jobs/$jobId/"));
    if (response.statusCode != 204) {
      throw Exception("Failed to delete maintenance job: ${response.body}");
    }
  }

  /// Send a computer sale item to maintenance (creates MaintenanceJob and marks computer)
  Future<Map<String, dynamic>> sendToMaintenance(String saleId, {String? customerName, String? reportedIssue, String? notes}) async {
    // Get token from shared prefs via AuthService
    final auth = AuthService();
    final token = await auth.getToken();

    final body = {
      if (customerName != null) 'customer_name': customerName,
      if (reportedIssue != null) 'reported_issue': reportedIssue,
      if (notes != null) 'notes': notes,
    };

    final response = await client.post(
      Uri.parse("$baseUrl/computer-sales/$saleId/send-to-maintenance/"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send to maintenance: ${response.body}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Mark maintenance job as completed and return computer to inventory
  Future<Map<String, dynamic>> returnFromMaintenance(String jobId) async {
    final auth = AuthService();
    final token = await auth.getToken();

    final response = await client.post(
      Uri.parse("$baseUrl/maintenance-jobs/$jobId/return-to-inventory/"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to return from maintenance: ${response.body}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }


  Future<List<ComputerSale>> getComputerSales() async {
    final response = await client.get(Uri.parse("$baseUrl/computer-sales/"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((sale) => ComputerSale.fromJson(sale)).toList();
    } else {
      throw Exception("Failed to load computer sales: ${response.body}");
    }
  }

  Future<ComputerSale> addComputerSale(ComputerSale sale) async {
    final Map<String, dynamic> body = Map<String, dynamic>.from(sale.toJson());
    // Remove id when creating; backend will assign AutoField id
    body.remove('id');

    final response = await client.post(
      Uri.parse("$baseUrl/computer-sales/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (response.statusCode == 201) {
      return ComputerSale.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to add computer sale: ${response.body}");
    }
  }

  Future<ComputerSale> updateComputerSale(ComputerSale sale) async {
    final response = await client.put(
      Uri.parse("$baseUrl/computer-sales/${sale.id}/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(sale.toJson()),
    );
    if (response.statusCode == 200) {
      return ComputerSale.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update computer sale: ${response.body}");
    }
  }

  /// Update sale status. Returns the parsed JSON response from the server.
  /// The backend returns an object containing the updated `computer` and `sold_item` when appropriate.
  Future<Map<String, dynamic>> updateSaleStatus(String id, SaleStatus status) async {
    final response = await client.patch(
      Uri.parse("$baseUrl/computer-sales/$id/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'status': status.name}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update sale status: ${response.body}");
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Sell multiple units of a computer. Sends quantity_sold in PATCH body.
  Future<Map<String, dynamic>> sellUnits(String id, int quantity) async {
    final response = await client.patch(
      Uri.parse("$baseUrl/computer-sales/$id/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'quantity_sold': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to sell units: ${response.body}");
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getSoldItems() async {
    final response = await client.get(Uri.parse("$baseUrl/sold-items/"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load sold items: ${response.body}");
    }
  }

  Future<void> deleteComputerSale(String id) async {
    final response = await client.delete(Uri.parse("$baseUrl/computer-sales/$id/"));
    if (response.statusCode != 204) {
      throw Exception("Failed to delete computer sale: ${response.body}");
    }
  }
}
