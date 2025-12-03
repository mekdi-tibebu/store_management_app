// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/services/auth_service.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'home_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math';

// class SubscriptionScreen extends StatefulWidget {
//   const SubscriptionScreen({super.key});

//   @override
//   State<SubscriptionScreen> createState() => _SubscriptionScreenState();
// }

// class _SubscriptionScreenState extends State<SubscriptionScreen> {
//   bool _loading = false;

//     Future<void> handlePayment() async {
//       setState(() => _loading = true);
//       final authService = AuthService();

//       try {
//         // 🔹 Get logged-in user info
//         final prefs = await SharedPreferences.getInstance();
//         final email = prefs.getString("user_email") ?? "default@example.com";
//         final userId = prefs.getString("user_id") ?? "guest";

//         // 🔹 Random amount between 5000 and 15000
//         final random = Random();
//         final amount = (5000 + random.nextDouble() * 10000).toInt();

//         // 🔹 Unique txRef
//         final txRef = "txn-$userId-${DateTime.now().millisecondsSinceEpoch}";

//         // 🔹 Ask backend to create Chapa transaction
//         final checkoutUrl = await authService.createChapaPayment(
//           amount: amount,
//           email: email,
//           txRef: txRef,
//         );

//         if (checkoutUrl != null && mounted) {
//           // Save txRef for later confirmation
//           await authService.savePendingTxRef(txRef);

//           // 🔹 Launch Chapa checkout
//           final uri = Uri.parse(checkoutUrl);
//           if (await canLaunchUrl(uri)) {
//             await launchUrl(uri, mode: LaunchMode.externalApplication);
//             // ⛔ Do NOT confirm here – will be done on app resume
//           } else {
//             _showError("Could not open payment page.");
//           }
//         } else {
//           _showError("Unable to start payment.");
//         }
//       } catch (e) {
//         _showError("Error: $e");
//       } finally {
//         if (mounted) setState(() => _loading = false);
//       }
//     }

    
//   void _showError(String msg) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // ✅ White background
//       appBar: AppBar(
//         backgroundColor: Colors.white, // ✅ Match clean UI
//         elevation: 0, // ✅ Flat app bar for modern UI
//         automaticallyImplyLeading: true, // ✅ Keeps back button but removes title
//         title: null, // ❌ Remove "Subscription" title
//       ),
//       body: Center(
//         child: InkWell(
//           onTap: _loading ? null : handlePayment,
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.green, width: 1.5),
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white, // ✅ Keep button clean on white background
//             ),
//             child: _loading
//                 ? const CircularProgressIndicator(color: Colors.green)
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Image.asset(
//                         "assets/chapa_logo.png",
//                         height: 30,
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         "Pay with Chapa",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

// }



import 'package:flutter/material.dart';
import 'package:computer_shop_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = false;

  // Future<void> handlePayment() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final email = prefs.getString("user_email");
  //   final token = prefs.getString("access");

  //   if (token == null) {
  //     print("No token found. Please login again.");
  //     return;
  //   }

  //   if (email == null || email.isEmpty) {
  //     print("User email not found. Please login again.");
  //     return;
  //   }

  //   print("Using email for payment: $email");

  //   final txRef = "txn_${DateTime.now().millisecondsSinceEpoch}";
  //   final paymentUrl = await createChapaPayment(
  //     amount: 5000,
  //     email: email,
  //     txRef: txRef,
  //   );

  //   if (paymentUrl != null) {
  //     print("Redirecting to payment URL...");
  //     if (await canLaunchUrl(Uri.parse(paymentUrl))) {
  //       await launchUrl(Uri.parse(paymentUrl));
  //     } else {
  //       print("Could not launch payment URL");
  //     }
  //   } else {
  //     print("Payment initiation failed");
  //   }
  // }

  

  Future<void> handlePayment() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("user_email");
    final token = prefs.getString("access");

    if (token == null) {
      _showError("Session expired. Please log in again.");
      setState(() => _loading = false);
      return;
    }

    if (email == null || email.isEmpty) {
      _showError("User email not found. Please log in again.");
      setState(() => _loading = false);
      return;
    }

    final txRef = "txn_${DateTime.now().millisecondsSinceEpoch}";
    final authService = AuthService(); // ✅ create instance

    final paymentUrl = await authService.createChapaPayment( // ✅ use instance
      amount: 5000,
      email: email,
      txRef: txRef,
    );

    setState(() => _loading = false);

    if (paymentUrl != null) {
      if (await canLaunchUrl(Uri.parse(paymentUrl))) {
        await launchUrl(Uri.parse(paymentUrl));
      } else {
        _showError("Could not open payment page.");
      }
    } else {
      _showError("Failed to initiate payment. Try again.");
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // 🎁 Image/Icon Placeholder (Replace with your image asset)
          Image.asset(
            "assets/subscription_gift.png", // Make sure you have this image
            height: 140,
          ),
          const SizedBox(height: 20),

          // 💳 Payment Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: InkWell(
              onTap: _loading ? null : handlePayment,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // ✅ Blue button like design
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xff0057FF), width: 2),
                ),
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/chapa_logo.png",
                            height: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Pay With Chapa",
                            style: TextStyle(
                              color: Color(0xff0057FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 📜 Terms & Info Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "By placing this order, you agree to the Terms of Service and Privacy Policy. "
              "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
