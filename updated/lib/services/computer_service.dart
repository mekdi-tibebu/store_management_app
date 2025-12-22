import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/computer.dart';
import 'auth_service.dart';

class ComputerService {
  final AuthService _authService = AuthService();
  
  // Get all computers
  Future<List<Computer>> getComputers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse(ApiConfig.computersEndpoint),
        headers: ApiConfig.authHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Computer.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Try to refresh token
        if (await _authService.refreshAccessToken()) {
          return getComputers(); // Retry
        }
      }
      
      throw Exception('Failed to load computers');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Add computer
  Future<Computer> addComputer(Computer computer) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.post(
        Uri.parse(ApiConfig.computersEndpoint),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(computer.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Computer.fromJson(jsonDecode(response.body));
      }
      
      throw Exception('Failed to add computer');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Update computer
  Future<Computer> updateComputer(int id, Computer computer) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.put(
        Uri.parse('${ApiConfig.computersEndpoint}$id/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(computer.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Computer.fromJson(jsonDecode(response.body));
      }
      
      throw Exception('Failed to update computer');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Delete computer
  Future<bool> deleteComputer(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.delete(
        Uri.parse('${ApiConfig.computersEndpoint}$id/'),
        headers: ApiConfig.authHeaders(token),
      );
      
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
  
  // Sell units
  Future<Computer> sellUnits(int id, int quantity) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.computersEndpoint}$id/sell/'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({'quantity': quantity}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Computer.fromJson(data['computer'] ?? data);
      }
      
      throw Exception('Failed to sell units');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
