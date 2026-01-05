import 'package:flutter/material.dart';
import '../models/computer_model.dart';
import '../services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  
  List<Computer> _computers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _stats = {};

  List<Computer> get computers => _computers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get stats => _stats;

  InventoryProvider() {
    _inventoryService.getUserComputers().listen((computers) {
      _computers = computers;
      notifyListeners();
    });
    loadStats();
  }

  Future<void> loadStats() async {
    _stats = await _inventoryService.getInventoryStats();
    notifyListeners();
  }

  Future<bool> addComputer(Computer computer) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.addComputer(computer);
      await loadStats();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComputer(String id, Computer computer) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.updateComputer(id, computer);
      await loadStats();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComputer(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.deleteComputer(id);
      await loadStats();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}