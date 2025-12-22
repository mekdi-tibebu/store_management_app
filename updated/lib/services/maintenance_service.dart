import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/maintenance_job.dart';
import 'auth_service.dart';

class MaintenanceService {
  final AuthService _authService = AuthService();
  
  // Get all maintenance jobs
  Future<List<MaintenanceJob>> getMaintenanceJobs() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse(ApiConfig.maintenanceEndpoint),
        headers: ApiConfig.authHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MaintenanceJob.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        if (await _authService.refreshAccessToken()) {
          return getMaintenanceJobs();
        }
      }
      
      throw Exception('Failed to load maintenance jobs');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Add maintenance job
  Future<MaintenanceJob> addMaintenanceJob(MaintenanceJob job) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.post(
        Uri.parse(ApiConfig.maintenanceEndpoint),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(job.toJson()),
      );
      
      if (response.statusCode == 201) {
        return MaintenanceJob.fromJson(jsonDecode(response.body));
      }
      
      throw Exception('Failed to add maintenance job');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Update maintenance job status
  Future<MaintenanceJob> updateJobStatus(int id, MaintenanceStatus status) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.patch(
        Uri.parse('${ApiConfig.maintenanceEndpoint}$id/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({'status': _statusToString(status)}),
      );
      
      if (response.statusCode == 200) {
        return MaintenanceJob.fromJson(jsonDecode(response.body));
      }
      
      throw Exception('Failed to update status');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  String _statusToString(MaintenanceStatus status) {
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
}
