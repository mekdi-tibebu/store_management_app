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

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  /// Get stored access token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<bool> hasActiveSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('active_subscription') ?? false;
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
      return data["is_paid"] ?? false;
    }
    return false;
  }

  Future<String?> createChapaPayment({
    required int amount,
    required String email,
    required String txRef,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    if (token == null) {
      print("❌ No access token found. Please log in again.");
      return null;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/start-payment/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "amount": amount.toString(),
        "email": email,
        "tx_ref": txRef,
      }),
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

  Future<bool> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "email": email,
        "password": password, // ✅ use "password", not password1/password2
      }),
    );

    print("Signup Response Code: ${response.statusCode}");
    print("Signup Response Body: ${response.body}");

    if (response.statusCode == 201) {
      return true; // success
    } else {
      return false; // failed
    }
  }

  Future<User?> login(String identifier, String password) async {
    final isEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(identifier);

    final Map<String, String> body = {
      "password": password,
      if (isEmail) "email": identifier else "username": identifier,
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

      // Always save identifier info
      await prefs.setString("user_identifier", identifier);
      await prefs.setBool("is_email", isEmail);

      // Fetch full user info if email missing
      String userEmail;
      String userUsername;

      if (isEmail) {
        userEmail = identifier;
        userUsername = data["username"] ?? "";
      } else {
        userUsername = identifier;
        // Try to get email from backend via /me/ endpoint
        final email = await fetchUserEmail(data["access"]);
        userEmail = email ?? "no-email@domain.com"; // fallback if still null
      }

      await prefs.setString("user_email", userEmail);
      await prefs.setString("user_username", userUsername);

      print("✅ Saved email: $userEmail");
      print("✅ Saved username: $userUsername");

      return User(
        id: data["id"]?.toString() ?? "",
        email: userEmail,
        username: userUsername,
        token: data["access"] ?? "",
      );
    } else {
      final error = jsonDecode(response.body);
      print("❌ Login failed: ${error["detail"] ?? response.body}");
      return null;
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
}
