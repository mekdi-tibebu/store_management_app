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
      final result = await _authService.signup(username, email, password);
      if (!mounted) return;
      
      if (result['success']) {
        // Navigate to email verification screen
        Navigator.pushReplacementNamed(
          context,
          '/email-verification',
          arguments: result['email'] ?? email,
        );
      } else {
        _showSnackBar(result['message'] ?? "Signup failed. Try a different email or check your connection.");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Signup error: ${e.toString()}");
      }
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
