// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/services/auth_service.dart';

// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   double _yOffset = 80;
//   double _opacity = 0;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(milliseconds: 200), () {
//       setState(() {
//         _yOffset = 0;
//         _opacity = 1;
//       });
//     });
//   }

//   Future<void> _signup() async {
//     final success = await _authService.signup(
//       _usernameController.text,
//       _emailController.text,
//       _passwordController.text,
//     );
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Signup successful, please login")),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Signup failed")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 600),
//           curve: Curves.easeOut,
//           transform: Matrix4.translationValues(0, _yOffset, 0),
//           child: AnimatedOpacity(
//             duration: Duration(milliseconds: 600),
//             opacity: _opacity,
//             child: Container(
//               padding: EdgeInsets.all(24),
//               width: 380,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     blurRadius: 15,
//                     spreadRadius: 2,
//                     offset: Offset(0, 8),
//                     color: Colors.black.withOpacity(0.1), // Soft gray shadow
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(
//                       labelText: "Username",
//                       labelStyle: TextStyle(color: Colors.blue),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue, width: 2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue.withOpacity(0.4)),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: "Email",
//                       labelStyle: TextStyle(color: Colors.blue),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue, width: 2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue.withOpacity(0.4)),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       labelStyle: TextStyle(color: Colors.blue),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue, width: 2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue.withOpacity(0.4)),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         padding: EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: _signup,
//                       child: Text("Create Account", style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:computer_shop_app/services/auth_service.dart'; // Assuming this path is correct

// // class SignupScreen extends StatefulWidget {
// //   @override
// //   _SignupScreenState createState() => _SignupScreenState();
// // }

// // class _SignupScreenState extends State<SignupScreen> {
// //   final _usernameController = TextEditingController(); // Corresponds to Name
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final AuthService _authService = AuthService();

// //   bool _isPasswordVisible = false;
// //   bool _agreedToTerms = false;
// //   bool _loading = false; // To indicate loading state for signup button
// //   String? _errorMessage; // To display signup errors

// //   Future<void> _signup() async {
// //     if (!_agreedToTerms) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Please agree to the terms and privacy policy")),
// //       );
// //       return;
// //     }

// //     setState(() {
// //       _loading = true;
// //       _errorMessage = null;
// //     });

// //     // Assuming the signup method expects username, email, password
// //     final success = await _authService.signup(
// //       _usernameController.text.trim(),
// //       _emailController.text.trim(),
// //       _passwordController.text.trim(),
// //     );

// //     setState(() => _loading = false);

// //     if (success) {
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Signup successful, please login")),
// //       );
// //       Navigator.pop(context); // Go back to login screen
// //     } else {
// //       setState(() {
// //         _errorMessage = "Signup failed. Please try again or use a different email.";
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text(_errorMessage!)),
// //       );
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _usernameController.dispose();
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
// //           onPressed: () {
// //             Navigator.pop(context); // Goes back to the previous screen (e.g., Login)
// //           },
// //         ),
// //         title: Text(
// //           'Back',
// //           style: TextStyle(color: Colors.black, fontSize: 18),
// //         ),
// //         titleSpacing: -10, // Adjust spacing to bring 'Back' closer to the arrow
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             SizedBox(height: 20), // Space below the app bar
// //             Text(
// //               'Sign up',
// //               style: TextStyle(
// //                 color: Color(0xFF003399), // Dark blue
// //                 fontSize: 36,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               'Please create a new account',
// //               style: TextStyle(
// //                 color: Colors.black,
// //                 fontSize: 16,
// //               ),
// //             ),
// //             SizedBox(height: 40),

// //             // Name Input (using _usernameController for Name as per your original code)
// //             Text(
// //               'Name',
// //               style: TextStyle(
// //                 color: Colors.black,
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //             SizedBox(height: 8),
// //             TextFormField(
// //               controller: _usernameController,
// //               decoration: InputDecoration(
// //                 hintText: 'Type something longer here...',
// //                 fillColor: Colors.grey[100], // Light grey background
// //                 filled: true,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide.none, // No border line
// //                 ),
// //                 contentPadding:
// //                     EdgeInsets.symmetric(vertical: 14, horizontal: 16),
// //               ),
// //               keyboardType: TextInputType.name,
// //             ),
// //             SizedBox(height: 24),

// //             // Email Input
// //             Text(
// //               'Email',
// //               style: TextStyle(
// //                 color: Colors.black,
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //             SizedBox(height: 8),
// //             TextFormField(
// //               controller: _emailController,
// //               decoration: InputDecoration(
// //                 hintText: 'myemail@gmail.com',
// //                 fillColor: Colors.white, // White background as in image
// //                 filled: true,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide(
// //                       color: Color(0xFF003399), width: 1.0), // Blue border
// //                 ),
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide(
// //                       color: Color(0xFF003399), width: 1.0), // Blue border
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide(
// //                       color: Color(0xFF003399),
// //                       width: 2.0), // Thicker blue border when focused
// //                 ),
// //                 contentPadding:
// //                     EdgeInsets.symmetric(vertical: 14, horizontal: 16),
// //               ),
// //               keyboardType: TextInputType.emailAddress,
// //             ),
// //             SizedBox(height: 24),

// //             // Password Input
// //             Text(
// //               'Password',
// //               style: TextStyle(
// //                 color: Colors.black,
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //             SizedBox(height: 8),
// //             TextFormField(
// //               controller: _passwordController,
// //               obscureText: !_isPasswordVisible,
// //               decoration: InputDecoration(
// //                 hintText: '••••••••••••',
// //                 fillColor: Colors.grey[100], // Light grey background
// //                 filled: true,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(8),
// //                   borderSide: BorderSide.none, // No border line
// //                 ),
// //                 contentPadding:
// //                     EdgeInsets.symmetric(vertical: 14, horizontal: 16),
// //                 suffixIcon: Padding(
// //                   padding: const EdgeInsets.only(right: 12.0),
// //                   child: IconButton(
// //                     icon: Icon(
// //                       _isPasswordVisible
// //                           ? Icons.visibility
// //                           : Icons.visibility_off,
// //                       color: Colors.blueGrey, // Eye icon color
// //                       size: 24,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _isPasswordVisible = !_isPasswordVisible;
// //                       });
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 24),

// //             // Checkbox for terms
// //             Row(
// //               children: [
// //                 SizedBox(
// //                   width: 24, // Standard checkbox size
// //                   height: 24,
// //                   child: Checkbox(
// //                     value: _agreedToTerms,
// //                     onChanged: (bool? newValue) {
// //                       setState(() {
// //                         _agreedToTerms = newValue ?? false;
// //                       });
// //                     },
// //                     activeColor: Color(0xFF003399), // Dark blue when checked
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(4), // Slightly rounded corners for checkbox
// //                     ),
// //                     side: BorderSide(
// //                       color: Colors.grey[600]!, // Grey border when unchecked
// //                       width: 1.5,
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(width: 8),
// //                 Expanded(
// //                   child: Text(
// //                     'Agree the terms of use and privacy policy',
// //                     style: TextStyle(
// //                       color: Colors.black,
// //                       fontSize: 15,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 32),

// //             // Sign Up Button
// //             Container(
// //               width: double.infinity,
// //               height: 50,
// //               child: ElevatedButton(
// //                 onPressed: _loading || !_agreedToTerms
// //                     ? null // Button disabled if loading or terms not agreed
// //                     : _signup,
// //                 child: _loading
// //                     ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
// //                     : Text(
// //                         'Sign up',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                 style: ElevatedButton.styleFrom(
// //                   primary: Color(0xFF003399), // Dark blue
// //                   onSurface: Color(0xFF003399).withOpacity(0.5), // Disabled color
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   elevation: 0,
// //                 ),
// //               ),
// //             ),
// //             if (_errorMessage != null) ...[
// //               const SizedBox(height: 12),
// //               Center(
// //                 child: Text(
// //                   _errorMessage!,
// //                   style: const TextStyle(color: Colors.red, fontSize: 14),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }



import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  double _yOffset = 80;
  double _opacity = 0;
  bool _loading = false;
  bool _isPasswordVisible = false;
  bool _agreedToTerms = true;
  bool _emailValid = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _yOffset = 0;
        _opacity = 1;
      });
    });

    _emailController.addListener(() {
      final isValid = _isValidEmail(_emailController.text.trim());
      if (isValid != _emailValid && mounted) {
        setState(() => _emailValid = isValid);
      }
    });
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  void _showSnackBar(String msg, {Color background = Colors.redAccent}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: background),
    );
  }

  Future<void> _signup() async {
    if (!_agreedToTerms) {
      _showSnackBar("Please agree to the terms and privacy policy.");
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields.");
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar("Please enter a valid email address.");
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await _authService.signup(username, email, password);
      if (!mounted) return;
      if (success) {
        _showSnackBar("Signup successful — please sign in.", background: Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackBar("Signup failed. Try a different email or check your connection.");
      }
    } catch (e) {
      _showSnackBar("Signup error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'myemail@gmail.com',
        fillColor: Colors.grey[100],
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        suffixIcon: _emailValid
            ? const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.check_circle, color: Color(0xFF42c633), size: 22),
              )
            : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width < 420 ? MediaQuery.of(context).size.width * 0.92 : 380.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _yOffset, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: _opacity,
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Create account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003399))),
                  ),
                  const SizedBox(height: 6),
                  const Align(alignment: Alignment.centerLeft, child: Text('Please create a new account', style: TextStyle(fontSize: 14))),
                  const SizedBox(height: 20),
                  // Username
                  const Align(alignment: Alignment.centerLeft, child: Text('Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Your full name',
                      fillColor: Colors.grey[100],
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  // Email
                  const Align(alignment: Alignment.centerLeft, child: Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 8),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  // Password
                  const Align(alignment: Alignment.centerLeft, child: Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 8),
                  _buildPasswordField(),
                  const SizedBox(height: 18),
                  // Terms
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) {
                            if (mounted) setState(() => _agreedToTerms = v ?? false);
                          },
                          activeColor: const Color(0xFF003399),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Agree to terms of use and privacy policy', style: TextStyle(fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Signup button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_loading || !_agreedToTerms) ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003399),
                        disabledBackgroundColor: const Color(0xFF003399).withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create Account', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Link to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Sign in", style: TextStyle(color: Color(0xFF003399))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
