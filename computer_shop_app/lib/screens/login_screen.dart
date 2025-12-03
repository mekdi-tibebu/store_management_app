// // import 'package:flutter/material.dart';
// // import 'package:computer_shop_app/services/auth_service.dart';

// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }

// // class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final AuthService _authService = AuthService();

// //   bool _loading = false;
// //   String? _error;

// //   late AnimationController _controller;
// //   late Animation<Offset> _slideAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = AnimationController(
// //       duration: const Duration(milliseconds: 500),
// //       vsync: this,
// //     );
// //     _slideAnimation = Tween<Offset>(
// //       begin: const Offset(0, 0.3),
// //       end: Offset.zero,
// //     ).animate(
// //       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
// //     );
// //     _controller.forward();
// //   }

// //   Future<void> login() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });

// //     final user = await _authService.login(
// //       _emailController.text.trim(),
// //       _passwordController.text.trim(),
// //     );

// //     setState(() => _loading = false);

// //     if (!mounted) return;

// //     if (user != null) {
// //       Navigator.pushReplacementNamed(context, '/subscription');
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Invalid username or password')),
// //       );
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Center(
// //         child: SlideTransition(
// //           position: _slideAnimation,
// //           child: Container(
// //             padding: const EdgeInsets.all(24),
// //             width: MediaQuery.of(context).size.width * 0.85,
// //             constraints: const BoxConstraints(maxWidth: 400),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(12),
// //               boxShadow: [
// //                 BoxShadow(
// //                   blurRadius: 12,
// //                   spreadRadius: 2,
// //                   offset: const Offset(0, 4),
// //                   color: Colors.grey.withOpacity(0.2),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 TextField(
// //                   controller: _emailController,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Username or Email',
// //                     labelStyle: TextStyle(color: Colors.blue),
// //                     focusedBorder: UnderlineInputBorder(
// //                       borderSide: BorderSide(color: Colors.blue),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 TextField(
// //                   controller: _passwordController,
// //                   obscureText: true,
// //                   decoration: const InputDecoration(
// //                     labelText: 'Password',
// //                     labelStyle: TextStyle(color: Colors.blue),
// //                     focusedBorder: UnderlineInputBorder(
// //                       borderSide: BorderSide(color: Colors.blue),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: login,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.blue,
// //                       padding: const EdgeInsets.symmetric(vertical: 14),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     child: _loading
// //                         ? const SizedBox(
// //                             height: 18,
// //                             width: 18,
// //                             child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
// //                           )
// //                         : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 TextButton(
// //                   onPressed: () => Navigator.pushNamed(context, "/signup"),
// //                   style: TextButton.styleFrom(foregroundColor: Colors.blue),
// //                   child: const Text("Don't have an account? Sign up"),
// //                 ),
// //                 if (_error != null) ...[
// //                   const SizedBox(height: 8),
// //                   Text(_error!, style: const TextStyle(color: Colors.red)),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/services/auth_service.dart'; // Assuming this path is correct

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   bool _loading = false;
//   String? _error;
//   bool _isPasswordVisible = false; // To toggle password visibility

//   Future<void> login() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     final user = await _authService.login(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );

//     setState(() => _loading = false);

//     if (!mounted) return;

//     if (user != null) {
//       // ✅ Login successful → go to subscription screen
//       Navigator.pushReplacementNamed(context, '/subscription');
//     } else {
//       // ❌ Login failed → show error
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid username or password')),
//       );
//       setState(() {
//         _error = "Invalid username or password"; // Set error for display below button
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context); // Goes back to the previous screen
//           },
//         ),
//         title: Text(
//           'Back',
//           style: TextStyle(color: Colors.black, fontSize: 18),
//         ),
//         titleSpacing: -10, // Adjust spacing to bring 'Back' closer to the arrow
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20), // Space below the app bar
//             Text(
//               'Sign in',
//               style: TextStyle(
//                 color: Color(0xFF003399), // Dark blue
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Please log in into your account',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 40),
//             Text(
//               'Email',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 hintText: 'myemail@gmail.com',
//                 fillColor: Colors.grey[100], // Light grey background
//                 filled: true,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none, // No border line
//                 ),
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                 suffixIcon: _emailController.text.isNotEmpty &&
//                         _emailController.text.contains('@') &&
//                         _emailController.text.contains('.')
//                     ? Padding(
//                         padding: const EdgeInsets.only(right: 12.0),
//                         child: Icon(Icons.check_circle,
//                             color: Colors.green, size: 24), // Checkmark icon
//                       )
//                     : null, // Only show checkmark if email looks valid
//               ),
//               keyboardType: TextInputType.emailAddress,
//               onChanged: (text) {
//                 setState(() {}); // Rebuild to show/hide checkmark based on input
//               },
//             ),
//             SizedBox(height: 24),
//             Text(
//               'Password',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !_isPasswordVisible,
//               decoration: InputDecoration(
//                 hintText: '••••••••••••',
//                 fillColor: Colors.grey[100], // Light grey background
//                 filled: true,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none, // No border line
//                 ),
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                 suffixIcon: Padding(
//                   padding: const EdgeInsets.only(right: 12.0),
//                   child: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.blueGrey, // Eye icon color
//                       size: 24,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerRight,
//               child: GestureDetector(
//                 onTap: () {
//                   // TODO: Implement forgot password logic
//                   print('Forgot password tapped');
//                 },
//                 child: Text(
//                   'Forgot password?',
//                   style: TextStyle(
//                     color: Color(0xFFE67827), // Orange color
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 32),
//             Container(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : login, // Disable button while loading
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
//                     : Text(
//                         'Sign in',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                         ),
//                       ),
//                 style: ElevatedButton.styleFrom(
//                   primary: Color(0xFF003399), // Dark blue
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//             if (_error != null) ...[
//               const SizedBox(height: 12),
//               Center(
//                 child: Text(
//                   _error!,
//                   style: const TextStyle(color: Colors.red, fontSize: 14),
//                 ),
//               ),
//             ],
//             SizedBox(height: 40), // Space before social sign-in buttons
//             Container(
//               width: double.infinity,
//               height: 50,
//               child: OutlinedButton.icon(
//                 onPressed: () {
//                   // TODO: Implement Google sign-in logic
//                   print('Sign in with Google pressed');
//                 },
//                 icon: Image.asset(
//                   'assets/google_logo.png', // Replace with your Google logo asset path
//                   height: 24.0,
//                 ),
//                 label: Text(
//                   'Sign in with Google',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   primary: Colors.black, // Text/icon color on press
//                   side: BorderSide(color: Colors.grey[300]!, width: 1),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   backgroundColor: Colors.white,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               height: 50,
//               child: OutlinedButton.icon(
//                 onPressed: () {
//                   // TODO: Implement Facebook sign-in logic
//                   print('Sign in with Facebook pressed');
//                 },
//                 icon: Image.asset(
//                   'assets/facebook_logo.png', // Replace with your Facebook logo asset path
//                   height: 24.0,
//                 ),
//                 label: Text(
//                   'Sign in with Facebook',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   primary: Colors.black, // Text/icon color on press
//                   side: BorderSide(color: Colors.grey[300]!, width: 1),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   backgroundColor: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Remember to add your Google and Facebook logo image assets to your Flutter project.
// // 1. Create a folder named 'assets' in your project root.
// // 2. Place your 'google_logo.png' and 'facebook_logo.png' (or similar) files inside it.
// // 3. Update your pubspec.yaml file to include the assets:
// //    flutter:
// //      uses-material-design: true
// //      assets:
// //        - assets/google_logo.png
// //        - assets/facebook_logo.png
// //
// // Then run 'flutter pub get'.


import 'package:flutter/material.dart';
import 'package:computer_shop_app/services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _isPasswordVisible = false;
  String? _error;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  Future<void> login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/subscription');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      setState(() => _error = "Invalid username or password");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Back", style: TextStyle(color: Colors.black, fontSize: 18)),
        titleSpacing: -10,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sign in',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF003399)),
              ),
              const SizedBox(height: 8),
              const Text('Please log in into your account', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 40),
              
              // Email Input
              const Text('Username or Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'myemail@gmail.com',
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  suffixIcon: isValidEmail(_emailController.text)
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Password Input
              const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.blueGrey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                  },
                  child: Text("Forgot Password?", style: TextStyle(color: Color(0xFFE67827), fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : login,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003399), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Sign in', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14))),
              ],

              const SizedBox(height: 40),

              // Google Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement Google login
                  },
                  icon: Image.asset('assets/google_logo.png', height: 24),
                  label: const Text('Sign in with Google', style: TextStyle(fontSize: 16, color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/signup"),
                  child: const Text("Don't have an account? Sign up", style: TextStyle(color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
