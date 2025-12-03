// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/screens/login_screen.dart';
// import 'package:computer_shop_app/screens/signup_screen.dart';
// import 'package:computer_shop_app/screens/home_screen.dart';
// import 'package:computer_shop_app/screens/subscription_screen.dart';
// import 'package:computer_shop_app/services/auth_service.dart';
// import 'package:app_links/app_links.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // Check if app was launched via deep link (cold start)
//   _appLinks.getInitialLink().then((uri) {
//     if (uri != null && uri.scheme == 'myapp' && uri.host == 'payment-success') {
//       Navigator.pushReplacementNamed(context, '/home');
//     }
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Computer Shop App",
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const AuthWrapper(),
//       routes: {
//         '/login': (_) => LoginScreen(),
//         '/signup': (_) => SignupScreen(),
//         '/subscription': (_) => SubscriptionScreen(),
//         '/home': (_) => HomeScreen(),
//       },
//     );
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   final AuthService _authService = AuthService();
//   final AppLinks _appLinks = AppLinks();

//   bool _loading = true;
//   Widget? _nextScreen;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuth();
//     _listenForDeepLinks(); // 👈 added
//   }

//   Future<void> _checkAuth() async {
//     try {
//       final loggedIn = await _authService.isLoggedIn();

//       if (!loggedIn) {
//         setState(() {
//           _nextScreen = LoginScreen();
//           _loading = false;
//         });
//         return;
//       }

//       final hasSub = await _authService.hasActiveSubscription();

//       setState(() {
//         if (hasSub) {
//           _nextScreen = HomeScreen();
//         } else {
//           _nextScreen = SubscriptionScreen();
//         }
//         _loading = false;
//       });
//     } catch (e) {
//       print("AuthWrapper error: $e");
//       setState(() {
//         _nextScreen = LoginScreen();
//         _loading = false;
//       });
//     }
//   }

//   void _listenForDeepLinks() {
//     _appLinks.uriLinkStream.listen((Uri? uri) {
//       if (uri != null && uri.scheme == 'myapp') {
//         if (uri.host == 'payment-success') {
//           print("Payment success deep link triggered!");
//           // Redirect to home page after successful payment
//           Navigator.pushReplacementNamed(context, '/home');
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return _nextScreen!;
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:computer_shop_app/screens/login_screen.dart';
// import 'package:computer_shop_app/screens/signup_screen.dart';
// import 'package:computer_shop_app/screens/home_screen.dart';
// import 'package:computer_shop_app/screens/welcome_page_screen.dart';
// import 'package:computer_shop_app/screens/successful_registration_screen.dart';
// import 'package:computer_shop_app/screens/subscription_screen.dart';
// import 'package:computer_shop_app/services/auth_service.dart';
// import 'package:app_links/app_links.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // Generated via flutterfire CLI

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Computer Shop App",
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const AuthWrapper(),
//       routes: {
//         '/welcome': (_) => WelcomeScreen(),
//         '/login': (_) => LoginScreen(),
//         '/signup': (_) => SignupScreen(),
//         '/signup-success': (_) => SignupSuccessScreen(),
//         '/subscription': (_) => SubscriptionScreen(),
//         '/home': (_) => HomeScreen(),
//       },
//       home: const WelcomeScreen(),
//     );
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   final AuthService _authService = AuthService();
//   final AppLinks _appLinks = AppLinks();

//   bool _loading = true;
//   Widget? _nextScreen;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuth();
//     _listenForDeepLinks();
//     _handleInitialDeepLink(); // ✅ Cold start deep link
//   }

//   Future<void> _handleInitialDeepLink() async {
//     try {
//       final Uri? uri = await _appLinks.getInitialLink();
//       if (uri != null && uri.scheme == 'myapp' && uri.host == 'payment-success') {
//         print("Initial deep link detected: $uri");
//         // Navigate after build completes
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushReplacementNamed(context, '/home');
//         });
//       }
//     } catch (e) {
//       print("Error handling initial deep link: $e");
//     }
//   }

//   Future<void> _checkAuth() async {
//     try {
//       final loggedIn = await _authService.isLoggedIn();

//       if (!loggedIn) {
//         setState(() {
//           _nextScreen = LoginScreen();
//           _loading = false;
//         });
//         return;
//       }

//       final hasSub = await _authService.hasActiveSubscription();

//       setState(() {
//         _nextScreen = hasSub ? HomeScreen() : SubscriptionScreen();
//         _loading = false;
//       });
//     } catch (e) {
//       print("AuthWrapper error: $e");
//       setState(() {
//         _nextScreen = LoginScreen();
//         _loading = false;
//       });
//     }
//   }

//   void _listenForDeepLinks() {
//     _appLinks.uriLinkStream.listen((Uri? uri) {
//       if (uri != null && uri.scheme == 'myapp' && uri.host == 'payment-success') {
//         print("Payment success deep link triggered!");
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return _nextScreen!;
//   }
// }


import 'package:flutter/material.dart';
import 'package:computer_shop_app/screens/welcome_page_screen.dart';
import 'package:computer_shop_app/screens/signup_screen.dart';
import 'package:computer_shop_app/screens/successful_registration_screen.dart';
import 'package:computer_shop_app/screens/login_screen.dart';
import 'package:computer_shop_app/screens/forgot_password_screen.dart';
import 'package:computer_shop_app/screens/subscription_screen.dart';
import 'package:computer_shop_app/screens/home_screen.dart';
import 'package:computer_shop_app/services/auth_service.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:computer_shop_app/screens/code_screen.dart';
import 'package:computer_shop_app/screens/reset_password_screen.dart';

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
      title: "Computer Shop App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      routes: {
        '/welcome': (_) => const WelcomePageScreen(),
        '/signup': (_) => const SignupScreen(),
        '/signup-success': (_) => SuccessfulRegistrationScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/subscription': (_) => const SubscriptionScreen(),
        '/home': (_) => const HomeScreen(),
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
