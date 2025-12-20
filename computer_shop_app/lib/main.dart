import 'package:flutter/material.dart';
import 'package:computer_shop_app/screens/welcome_page_screen.dart';
import 'package:computer_shop_app/screens/signup_screen.dart';
import 'package:computer_shop_app/screens/successful_registration_screen.dart';
import 'package:computer_shop_app/screens/login_screen.dart';
import 'package:computer_shop_app/screens/forgot_password_screen.dart';
import 'package:computer_shop_app/screens/subscription_screen.dart';
import 'package:computer_shop_app/screens/home_screen.dart';
import 'package:computer_shop_app/screens/payment_success_screen.dart';
import 'package:computer_shop_app/services/auth_service.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:computer_shop_app/screens/code_screen.dart';
import 'package:computer_shop_app/screens/reset_password_screen.dart';
import 'package:computer_shop_app/screens/email_verification_screen.dart';
import 'package:computer_shop_app/widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Store Management",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      routes: {
        '/welcome': (_) => const WelcomePageScreen(),
        '/signup': (_) => const SignupScreen(),
        '/signup-success': (_) => SuccessfulRegistrationScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/subscription': (_) => AuthGuard(child: const SubscriptionScreen()),
        '/home': (_) => AuthGuard(child: const HomeScreen()),
        '/payment-success': (_) => AuthGuard(child: const PaymentSuccessScreen()),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/email-verification') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: email),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final AppLinks _appLinks = AppLinks();
  bool _loading = true;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _listenForDeepLinks();
    _handleInitialDeepLink();
  }

  /// ✅ Handles cold start deep links (after payment)
  Future<void> _handleInitialDeepLink() async {
    try {
      final Uri? uri = await _appLinks.getInitialLink();
      if (uri != null && uri.scheme == 'myapp' && uri.host == 'payment-success') {
        print("Initial deep link detected: $uri");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
        });
      }
    } catch (e) {
      print("Error handling initial deep link: $e");
    }
  }

  /// ✅ Listen for deep links while app is running
  void _listenForDeepLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'myapp' && uri.host == 'payment-success') {
        print("Payment success deep link triggered!");
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  /// ✅ Determine which screen to show on app start
  Future<void> _checkAuth() async {
    try {
      final loggedIn = await _authService.isLoggedIn();

      if (!loggedIn) {
        setState(() {
          _nextScreen = const WelcomePageScreen();
          _loading = false;
        });
        return;
      }

      final hasSub = await _authService.hasActiveSubscription();
      setState(() {
        _nextScreen = hasSub ? const HomeScreen() : const SubscriptionScreen();
        _loading = false;
      });
    } catch (e) {
      print("AuthWrapper error: $e");
      setState(() {
        _nextScreen = const WelcomePageScreen();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _nextScreen!;
  }
}
