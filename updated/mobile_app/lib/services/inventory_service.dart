import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Added
import 'package:image_picker/image_picker.dart'; // Added
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // Added
import '../models/computer_model.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all computers for current user
  Stream<List<Computer>> getUserComputers() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('computers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Computer.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String?> _uploadImage(XFile? file, String folder) async {
    if (file == null) return null;
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(folder).child(fileName);
      
      if (kIsWeb) {
        // For Browser
        final bytes = await file.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // For Mobile
        await ref.putFile(File(file.path));
      }
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Firebase Storage Error: $e");
      return null;
    }
  }


  // Get single computer by ID
  Future<Computer?> getComputer(String computerId) async {
    try {
      final doc = await _firestore.collection('computers').doc(computerId).get();
      if (!doc.exists) return null;
      return Computer.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw 'Failed to load computer: $e';
    }
  }

  Future<String> addComputer(Computer computer, {XFile? imageFile}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // 1. Upload the image first
      String? url = await _uploadImage(imageFile, 'inventory');

      // 2. Create the data with the new URL
      final computerData = computer.copyWith(
        userId: userId,
        imageUrl: url, // Ensure your Computer model has this field
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final doc = await _firestore.collection('computers').add(computerData.toJson());
      return doc.id;
    } catch (e) {
      throw 'Failed to add computer: $e';
    }
  }


  Future<void> updateComputer(String computerId, Computer computer, {XFile? newImageFile}) async {
    try {
      String? imageUrl = computer.imageUrl;

      // 1. Only upload if a new file was picked
      if (newImageFile != null) {
        imageUrl = await _uploadImage(newImageFile, 'inventory');
      }

      final updatedData = computer.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      // 2. Use .update to preserve fields and prevent "deletion" bugs
      await _firestore.collection('computers').doc(computerId).update(updatedData.toJson());
    } catch (e) {
      throw 'Failed to update computer: $e';
    }
  }


  // Delete computer
  Future<void> deleteComputer(String computerId) async {
    try {
      await _firestore.collection('computers').doc(computerId).delete();
    } catch (e) {
      throw 'Failed to delete computer: $e';
    }
  }

  // Search computers
  Stream<List<Computer>> searchComputers(String query) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('computers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final computers = snapshot.docs
          .map((doc) => Computer.fromJson(doc.data(), doc.id))
          .toList();

      if (query.isEmpty) return computers;

      // Filter by name, brand, or category
      return computers.where((computer) {
        final lowerQuery = query.toLowerCase();
        return computer.name.toLowerCase().contains(lowerQuery) ||
            computer.brand.toLowerCase().contains(lowerQuery) ||
            computer.category.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  // Get computers by category
  Stream<List<Computer>> getComputersByCategory(String category) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('computers')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Computer.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Get low stock computers (quantity <= 5)
  Stream<List<Computer>> getLowStockComputers() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return getUserComputers().map((computers) {
      return computers.where((computer) => computer.quantity <= 5).toList();
    });
  }

 

  Future<void> updateStock(String computerId, int quantity) async {
    try {
      await _firestore.collection('computers').doc(computerId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update stock: $e';
    }
  }

  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final snapshot = await _firestore
          .collection('computers')
          .where('userId', isEqualTo: userId)
          .get();

      final computers = snapshot.docs
          .map((doc) => Computer.fromJson(doc.data(), doc.id))
          .toList();

      return {
        'totalItems': computers.length,
        'totalQuantity': computers.fold(0, (sum, c) => sum + c.quantity),
        'totalValue': computers.fold(0.0, (sum, c) => sum + (c.price * c.quantity)),
        'lowStockCount': computers.where((c) => c.quantity <= 5).length,
      };
    } catch (e) {
      return {};
    }
  }

  Future<void> recordSale(Computer item, int qty) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    await _firestore.collection('sales').add({
      'userId': _auth.currentUser?.uid,
      // 'total': item.price * qty,
      'productId': item.id,
      'name': item.name,
      'category': item.category,
      'soldPrice': item.price,
      'costPrice': item.costPrice,
      'imageUrl': item.imageUrl, // Capture image in sale history
      'quantity': qty,
      'totalRevenue': item.price * qty,
      'totalCost': item.costPrice * qty,
      'profit': (item.price - item.costPrice) * qty,
      'createdAt': FieldValue.serverTimestamp(), // Changed 'timestamp' to match your report logic
      'userId': userId,
    });
  }
}