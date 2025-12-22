import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/subscription/subscription_screen.dart';

class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  
  const SubscriptionGuard({super.key, required this.child});

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  final AuthService _authService = AuthService();
  bool _hasSubscription = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final hasSubscription = await _authService.checkSubscription();
    
    if (mounted) {
      setState(() {
        _hasSubscription = hasSubscription;
        _loading = false;
      });
    }

    if (!hasSubscription && mounted) {
      // Redirect to subscription page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SubscriptionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasSubscription) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}
