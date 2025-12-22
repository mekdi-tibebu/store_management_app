import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/computer.dart';
import '../models/maintenance_job.dart';
import '../services/auth_service.dart';
import '../services/computer_service.dart';
import '../services/maintenance_service.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ComputerService _computerService = ComputerService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  
  User? _currentUser;
  List<Computer> _computers = [];
  List<MaintenanceJob> _maintenanceJobs = [];
  bool _loading = false;
  
  User? get currentUser => _currentUser;
  List<Computer> get computers => _computers;
  List<MaintenanceJob> get maintenanceJobs => _maintenanceJobs;
  bool get isLoading => _loading;
  
  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    final result = await _authService.login(email, password);
    if (result['success'] == true) {
      _currentUser = await _authService.getCurrentUser();
    }
    _setLoading(false);
    return result;
  }
  
  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    _setLoading(true);
    final result = await _authService.signup(username, email, password);
    _setLoading(false);
    return result;
  }
  
  Future<bool> verifyEmail(String email, String otp) async {
    return await _authService.verifyEmail(email, otp);
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _computers = [];
    _maintenanceJobs = [];
    notifyListeners();
  }
  
  Future<bool> checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    }
    return isLoggedIn;
  }
  
  // Computer methods
  Future<void> loadComputers() async {
    try {
      _setLoading(true);
      _computers = await _computerService.getComputers();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  Future<void> addComputer(Computer computer) async {
    try {
      final newComputer = await _computerService.addComputer(computer);
      _computers.insert(0, newComputer);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateComputer(int id, Computer computer) async {
    try {
      final updated = await _computerService.updateComputer(id, computer);
      final index = _computers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _computers[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteComputer(int id) async {
    try {
      final success = await _computerService.deleteComputer(id);
      if (success) {
        _computers.removeWhere((c) => c.id == id);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> sellUnits(int id, int quantity) async {
    try {
      final updated = await _computerService.sellUnits(id, quantity);
      final index = _computers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _computers[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Maintenance methods
  Future<void> loadMaintenanceJobs() async {
    try {
      _setLoading(true);
      _maintenanceJobs = await _maintenanceService.getMaintenanceJobs();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
  
  Future<void> addMaintenanceJob(MaintenanceJob job) async {
    try {
      final newJob = await _maintenanceService.addMaintenanceJob(job);
      _maintenanceJobs.insert(0, newJob);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateJobStatus(int id, MaintenanceStatus status) async {
    try {
      final updated = await _maintenanceService.updateJobStatus(id, status);
      final index = _maintenanceJobs.indexWhere((j) => j.id == id);
      if (index != -1) {
        _maintenanceJobs[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Statistics
  int get availableComputersCount => 
      _computers.where((c) => c.status == ComputerStatus.available).length;
  
  int get soldComputersCount => 
      _computers.where((c) => c.status == ComputerStatus.sold).length;
  
  int get maintenanceComputersCount => 
      _computers.where((c) => c.status == ComputerStatus.maintenance).length;
  
  int get pendingJobsCount =>
      _maintenanceJobs.where((j) => j.status == MaintenanceStatus.pending).length;
  
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
