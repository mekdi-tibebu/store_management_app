import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/computer_sale.dart';
import '../models/maintenance_job.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000/api";
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
    final response = await client.post(
      Uri.parse("$baseUrl/computer-sales/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(sale.toJson()),
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

  Future<void> updateSaleStatus(String id, SaleStatus status) async {
    final response = await client.patch(
      Uri.parse("$baseUrl/computer-sales/$id/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'status': status.name}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update sale status: ${response.body}");
    }
  }

  Future<void> deleteComputerSale(String id) async {
    final response = await client.delete(Uri.parse("$baseUrl/computer-sales/$id/"));
    if (response.statusCode != 204) {
      throw Exception("Failed to delete computer sale: ${response.body}");
    }
  }
}
