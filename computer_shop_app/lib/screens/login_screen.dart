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

    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      // Login successful
      final hasSub = await _authService.hasActiveSubscription();
      if (mounted) {
        Navigator.pushReplacementNamed(context, hasSub ? '/home' : '/subscription');
      }
    } else if (result['email_not_verified'] == true) {
      // Email not verified - redirect to verification screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Please verify your email'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        '/email-verification',
        arguments: result['email'],
      );
    } else {
      // Login failed
      final errorMsg = result['message'] ?? 'Invalid username or password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      setState(() => _error = errorMsg);
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

              // const SizedBox(height: 40),
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
