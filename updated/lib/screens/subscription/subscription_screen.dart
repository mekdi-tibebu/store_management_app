import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = true;
  bool _loadingPayment = false;
  String? _selectedPlan;
  final TextEditingController _couponController = TextEditingController();
  bool _validatingCoupon = false;
  Map<String, dynamic>? _couponData;
  List<Map<String, dynamic>> _plans = [];
  
  @override
  void initState() {
    super.initState();
    _loadPricing();
  }
  
  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPricing() async {
    setState(() => _loading = true);
    
    final authService = AuthService();
    final pricing = await authService.getSubscriptionPricing();
    
    if (mounted) {
      setState(() {
        _plans = pricing;
        _loading = false;
        
        // Auto-select first plan if available
        if (_plans.isNotEmpty) {
          _selectedPlan = _plans[0]['id'].toString();
        }
      });
    }
  }

  Future<void> _validateCoupon() async {
    final couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) {
      setState(() => _couponData = null);
      return;
    }

    if (_selectedPlan == null) {
      _showError("Please select a plan first");
      return;
    }

    setState(() => _validatingCoupon = true);

    final selectedPlanData = _plans.firstWhere((plan) => plan['id'].toString() == _selectedPlan);
    final amount = ((selectedPlanData['amount'] as num?)?.toInt() ?? 0);

    final authService = AuthService();
    final result = await authService.validateCoupon(couponCode, amount);

    setState(() {
      _validatingCoupon = false;
      _couponData = result;
    });

    if (mounted) {
      if (result['valid'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Coupon applied!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Invalid coupon'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedPlan == null) {
      _showError("Please select a plan");
      return;
    }

    final selectedPlanData = _plans.firstWhere((plan) => plan['id'].toString() == _selectedPlan);
    final amount = ((selectedPlanData['amount'] as num?)?.toInt() ?? 0);

    final provider = Provider.of<AppProvider>(context, listen: false);
    final email = provider.currentUser?.email ?? "";
    final couponCode = _couponController.text.trim();

    setState(() => _loadingPayment = true);

    final authService = AuthService();
    final paymentUrl = await authService.createChapaPayment(
      amount: amount,
      email: email,
      txRef: "TXN-${DateTime.now().millisecondsSinceEpoch}",
      couponCode: couponCode.isNotEmpty ? couponCode : null,
    );

    setState(() => _loadingPayment = false);

    if (paymentUrl != null) {
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment page opened. Complete payment and return to the app.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        _showError("Could not open payment page.");
      }
    } else {
      _showError("Failed to initiate payment. Try again.");
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  int _getFinalAmount() {
    if (_selectedPlan == null) return 0;
    final selectedPlanData = _plans.firstWhere((plan) => plan['id'].toString() == _selectedPlan);
    final amount = ((selectedPlanData['amount'] as num?)?.toInt() ?? 0);
    
    if (_couponData != null && _couponData!['valid'] == true) {
      return (_couponData!['final_amount'] as num).toInt();
    }
    return amount;
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['id'].toString();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan['id'].toString();
          _couponData = null;
        });
        if (_couponController.text.isNotEmpty) {
          _validateCoupon();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.bgCard,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? AppTheme.glowShadow(AppTheme.primaryBlue) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${plan['amount']} ETB',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
              ),
            ),
            if (plan['description'] != null && plan['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                plan['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white.withOpacity(0.9) : AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.bgDark,
              AppTheme.primaryBlue.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'Choose Your Plan',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a subscription to access all features',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Plans
                      ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
                      
                      const SizedBox(height: 24),
                      
                      // Coupon Code Section
                      Text(
                        'Have a coupon code?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              onChanged: (_) => setState(() => _couponData = null),
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Enter coupon code',
                                hintStyle: TextStyle(color: AppTheme.textSecondary),
                                filled: true,
                                fillColor: AppTheme.bgCard,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _validatingCoupon ? null : _validateCoupon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              child: _validatingCoupon
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Apply',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Coupon Success Message
                      if (_couponData != null && _couponData!['valid'] == true) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.successGreen),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✓ ${_couponData!['message']}',
                                style: const TextStyle(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Discount: ${_couponData!['discount_amount']} ETB',
                                style: const TextStyle(color: AppTheme.successGreen),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Payment Summary
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Original Amount:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${_selectedPlan != null ? _plans.firstWhere((p) => p['id'].toString() == _selectedPlan)['amount'] : 0} ETB',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textPrimary,
                                    decoration: _couponData != null && _couponData!['valid'] == true
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            if (_couponData != null && _couponData!['valid'] == true) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Final Amount:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                  Text(
                                    '${_getFinalAmount()} ETB',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.glowShadow(AppTheme.primaryBlue),
                          ),
                          child: ElevatedButton(
                            onPressed: (_loadingPayment || _selectedPlan == null) ? null : _handlePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _loadingPayment
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Continue to Payment',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
