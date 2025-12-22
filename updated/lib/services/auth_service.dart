import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access'], data['refresh']);
        
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          await _saveUser(user);
        }
        
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Signup
  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signupEndpoint),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'email': data['email'] ?? email,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Verify Email
  Future<bool> verifyEmail(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyEmailEndpoint),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
  
  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
  
  // Private helpers
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
  
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  // Refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) return false;
      
      final response = await http.post(
        Uri.parse(ApiConfig.refreshTokenEndpoint),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(_tokenKey, data['access']);
        return true;
      }
    } catch (e) {
      // Ignore
    }
    return false;
  }
  
  // Subscription Methods
  
  /// Get subscription pricing options from backend
  Future<List<Map<String, dynamic>>> getSubscriptionPricing() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/subscription-pricing/'),
        headers: ApiConfig.jsonHeaders,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print("Error fetching subscription pricing: $e");
    }
    return [];
  }
  
  /// Check if user has active subscription
  Future<bool> checkSubscription() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/check-subscription/'),
        headers: {
          ...ApiConfig.jsonHeaders,
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_paid'] == true;
      }
    } catch (e) {
      print("Error checking subscription: $e");
    }
    return false;
  }
  
  /// Create Chapa payment
  Future<String?> createChapaPayment({
    required int amount,
    required String email,
    required String txRef,
    String? couponCode,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/create-payment/'),
        headers: {
          ...ApiConfig.jsonHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'email': email,
          'tx_ref': txRef,
          if (couponCode != null) 'coupon_code': couponCode,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment_url'];
      }
    } catch (e) {
      print("Error creating payment: $e");
    }
    return null;
  }
  
  /// Validate coupon code
  Future<Map<String, dynamic>> validateCoupon(String couponCode, int amount) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'valid': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/validate-coupon/'),
        headers: {
          ...ApiConfig.jsonHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'coupon_code': couponCode,
          'amount': amount,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {'valid': false, 'error': error['error'] ?? 'Invalid coupon'};
      }
    } catch (e) {
      print("Error validating coupon: $e");
      return {'valid': false, 'error': 'Network error'};
    }
  }
}
