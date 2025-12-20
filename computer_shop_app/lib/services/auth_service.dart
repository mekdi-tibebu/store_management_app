// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AuthService {
//   final String baseUrl = "http://127.0.0.1:8000/api";

//   /// Get stored access token
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString("access"); // ✅ Fixed
//   }

//   /// Save tokens
//   Future<void> saveTokens(String access, String refresh) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("access", access);
//     await prefs.setString("refresh", refresh);
//   }

//   /// Clear tokens (Logout)
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }

//   /// Check if user has active subscription
//   Future<bool> checkSubscription() async {
//     final token = await getToken();
//     if (token == null) return false;

//     final response = await http.get(
//       Uri.parse("$baseUrl/check-subscription/"),
//       headers: {"Authorization": "Bearer $token"},
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data["is_paid"] ?? false;
//     }
//     return false;
//   }

//   /// Create Chapa Payment
//   Future<String?> createChapaPayment({
//     required int amount,
//     required String email,
//     required String txRef,
//   }) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/create-payment/"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({
//         "amount": amount.toString(),
//         "email": email,
//         "tx_ref": txRef,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data["data"]["checkout_url"];
//     }
//     return null;
//   }

//   /// Confirm Chapa payment (after callback/verify)
//   // Future<bool> confirmPayment(String txRef) async {
//   //   final token = await getToken();
//   //   if (token == null) return false;

//   //   final response = await http.post(
//   //     Uri.parse("$baseUrl/confirm-payment/"),
//   //     headers: {
//   //       "Authorization": "Bearer $token",
//   //       "Content-Type": "application/json",
//   //     },
//   //     body: json.encode({"tx_ref": txRef}),
//   //   );

//   //   if (response.statusCode == 200) {
//   //     final data = json.decode(response.body);
//   //     return data["status"] == "success";
//   //   }
//   //   return false;
//   // }

//       /// Confirm Chapa payment (after callback/verify)
//   Future<bool> confirmPayment({required String txRef}) async {
//     final token = await getToken();
//     if (token == null) return false;

//     final response = await http.post(
//       Uri.parse("$baseUrl/confirm-payment/"),
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//       },
//       body: json.encode({"tx_ref": txRef}), // ✅ use the txRef passed in
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data["status"] == "success";
//     }
//     return false;
//   }


//   /// Launch payment page
//   Future<void> launchPaymentUrl(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       throw "Could not launch $url";
//     }
//   }

//   /// Signup
//   Future<bool> signup(String username, String email, String password) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/signup/"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({
//         "username": username,
//         "email": email,
//         "password": password,
//       }),
//     );

//     if (response.statusCode == 201) {
//       final data = json.decode(response.body);
//       await saveTokens(data["access"], data["refresh"]);
//       return true;
//     }
//     return false;
//   }

//   /// Login
//   Future<bool> login(String username, String password) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/login/"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({
//         "username": username,
//         "password": password,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       await saveTokens(data["access"], data["refresh"]);
//       return true;
//     }
//     return false;
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final String baseUrl = "https://computer-shop-backend-4uyg.onrender.com/api";

  /// Get stored access token with automatic refresh if expired
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("access");
    
    if (accessToken == null) return null;
    
    // Check if token is expired and refresh if needed
    if (await _isTokenExpired(accessToken)) {
      print('Token expired, attempting refresh...');
      final refreshed = await refreshToken();
      if (refreshed) {
        return prefs.getString("access");
      }
      return null; // Refresh failed
    }
    
    return accessToken;
  }
  
  /// Check if JWT token is expired
  Future<bool> _isTokenExpired(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);
      
      final exp = data['exp'];
      if (exp == null) return true;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      // Consider token expired if it expires in less than 5 minutes
      return expiryDate.isBefore(now.add(const Duration(minutes: 5)));
    } catch (e) {
      print('Error checking token expiry: $e');
      return true;
    }
  }
  
  /// Refresh access token using refresh token
  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString("refresh");
      
      if (refreshToken == null) {
        print('No refresh token available');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access', data['access']);
        print('✅ Token refreshed successfully');
        return true;
      } else {
        print('❌ Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<bool> hasActiveSubscription() async {
    // Check with backend and update local prefs
    return await checkSubscription();
  }

  /// Get subscription pricing options from backend
  Future<List<Map<String, dynamic>>> getSubscriptionPricing() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/subscription-pricing/"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['name'],
          'price': (item['amount'] as num).toInt(),
          'description': item['description'] ?? '',
          'display_order': item['display_order'] ?? 0,
        }).toList();
      }
    } catch (e) {
      print("Error fetching subscription pricing: $e");
    }
    
    // Return default pricing if API fails
    return [
      {
        'id': 1,
        'name': 'Lifetime Access',
        'price': 5000,
        'description': 'One-time payment for lifetime access',
        'display_order': 0,
      }
    ];
  }

  /// Check if user has active subscription
  Future<bool> checkSubscription() async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse("$baseUrl/check-subscription/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final isPaid = data["is_paid"] ?? false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('active_subscription', isPaid);
      return isPaid;
    }
    return false;
  }

  Future<String?> createChapaPayment({
    required int amount,
    required String email,
    required String txRef,
    String? couponCode,
    String? frontendUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    if (token == null) {
      print("❌ No access token found. Please log in again.");
      return null;
    }

    final body = {
      "amount": amount.toString(),
      "email": email,
      "tx_ref": txRef,
    };
    
    if (couponCode != null && couponCode.isNotEmpty) {
      body["coupon_code"] = couponCode;
    }

    if (frontendUrl != null) {
      body["frontend_url"] = frontendUrl;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/start-payment/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(body),
    );

    print("🧾 Payment Response Code: ${response.statusCode}");
    print("🧾 Payment Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["payment_url"];
    } else {
      print("❌ Payment creation failed: ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>> validateCoupon(String couponCode, int amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/validate-coupon/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "coupon_code": couponCode,
        "amount": amount,
      }),
    );

    print("Coupon Validation Response: ${response.statusCode}");
    print("Coupon Validation Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"valid": false, "error": "Failed to validate coupon"};
    }
  }

  /// Confirm Chapa payment
  Future<bool> confirmPayment({required String txRef}) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/confirm-payment/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"tx_ref": txRef}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["status"] == "success";
    }
    return false;
  }

  /// Launch payment page in browser/app
  Future<void> launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

      /// Save last transaction reference (for resume confirmation)
  Future<void> savePendingTxRef(String txRef) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("pending_tx_ref", txRef);
  }

  Future<String?> getPendingTxRef() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("pending_tx_ref");
  }

  Future<void> clearPendingTxRef() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("pending_tx_ref");
  }

  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    print("Signup Response Code: ${response.statusCode}");
    print("Signup Response Body: ${response.body}");

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'Signup successful',
        'email': data['email'] ?? email,
      };
    } else {
      final error = json.decode(response.body);
      return {
        'success': false,
        'message': error['error'] ?? 'Signup failed',
      };
    }
  }

  /// Verify email with OTP code
  Future<bool> verifyEmail(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-email/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "otp": otp,
      }),
    );

    print("Verify Email Response Code: ${response.statusCode}");
    print("Verify Email Response Body: ${response.body}");

    return response.statusCode == 200;
  }

  /// Resend verification code
  Future<bool> resendVerificationCode(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/resend-verification-code/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
      }),
    );

    print("Resend Code Response Code: ${response.statusCode}");
    print("Resend Code Response Body: ${response.body}");

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final isEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(identifier);

    final Map<String, String> body = {
      "password": password,
      "identifier": identifier,  // Send as identifier, backend will handle it
    };

    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    print("🔵 Login Response Code: ${response.statusCode}");
    print("🔵 Login Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // Save tokens
      await prefs.setString("access", data["access"] ?? "");
      await prefs.setString("refresh", data["refresh"] ?? "");

      // Save user info
      final userInfo = data["user"];
      await prefs.setString("user_email", userInfo["email"] ?? "");
      await prefs.setString("user_username", userInfo["username"] ?? "");
      await prefs.setString("user_identifier", identifier);
      await prefs.setBool("is_email", isEmail);

      print("✅ Saved email: ${userInfo["email"]}");
      print("✅ Saved username: ${userInfo["username"]}");

      return {
        'success': true,
        'user': User(
          id: userInfo["id"]?.toString() ?? "",
          email: userInfo["email"] ?? "",
          username: userInfo["username"] ?? "",
          token: data["access"] ?? "",
        )
      };
    } else if (response.statusCode == 403) {
      // Email not verified
      final data = jsonDecode(response.body);
      if (data["email_not_verified"] == true) {
        return {
          'success': false,
          'email_not_verified': true,
          'email': data["email"],
          'message': data["message"] ?? "Please verify your email before logging in"
        };
      }
      return {
        'success': false,
        'message': data["message"] ?? "Login failed"
      };
    } else {
      final error = jsonDecode(response.body);
      print("❌ Login failed: ${error["error"] ?? response.body}");
      return {
        'success': false,
        'message': error["error"] ?? error["message"] ?? "Invalid credentials"
      };
    }
  }

  /// Helper to fetch user info from backend
  Future<String?> fetchUserEmail(String accessToken) async {
    final response = await http.get(
      Uri.parse("$baseUrl/me/"),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["email"];
    }
    return null;
  }

   Future<bool> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/password-reset/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email}),
    );

    return response.statusCode == 200;
  }

  /// Confirm password reset (with token from email)
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/password-reset-confirm/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "token": token,
        "new_password": newPassword,
      }),
    );

    return response.statusCode == 200;
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==================== Computer Sales CRUD ====================
  
  /// Get all computer sales
  Future<List<Map<String, dynamic>>> getComputerSales() async {
    final token = await getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/computer-sales/"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("Error fetching computer sales: $e");
    }
    return [];
  }

  /// Create new computer sale
  Future<bool> createComputerSale({
    required String model,
    required String specs,
    required double price,
    required int quantity,
    required String status,
  }) async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/computer-sales/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": model,
          "specs": specs,
          "price": price,
          "quantity": quantity,
          // Ensure status matches backend choice formatting (capitalize)
          "status": status.isNotEmpty ? (status[0].toUpperCase() + status.substring(1)) : status,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error creating computer sale: $e");
      return false;
    }
  }

  /// Update computer sale
  Future<bool> updateComputerSale({
    required int id,
    required String model,
    required String specs,
    required double price,
    required int quantity,
    required String status,
  }) async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/computer-sales/$id/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": model,
          "specs": specs,
          "price": price,
          "quantity": quantity,
          "status": status.isNotEmpty ? (status[0].toUpperCase() + status.substring(1)) : status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating computer sale: $e");
      return false;
    }
  }

  /// Delete computer sale
  Future<bool> deleteComputerSale(int id) async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/computer-sales/$id/"),
        headers: {"Authorization": "Bearer $token"},
      );

      return response.statusCode == 204;
    } catch (e) {
      print("Error deleting computer sale: $e");
      return false;
    }
  }
}
