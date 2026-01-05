import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/sales_provider.dart';
import '../inventory/inventory_list_screen.dart';
import '../sales/sales_history_screen.dart';
import '../sales/new_sale_screen.dart';
import '../reports/reports_screen.dart';
import '../subscription/subscription_wall_screen.dart';
import '../maintenance/maintenance_screen.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    await Future.wait([
      inventoryProvider.loadStats(),
      salesProvider.loadStats(),
    ]);
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return DashboardHome(
          onNavigateToSubscription: () {
            setState(() {
              _selectedIndex = 4; // Updated to point to subscription
            });
          },
        );
      case 1:
        return const InventoryListScreen();
      case 2:
        return const SalesHistoryScreen();
      case 3:
        return const MaintenanceScreen();
      case 4:
        return const SubscriptionWallScreen();
      default:
        return DashboardHome(
          onNavigateToSubscription: () {
            setState(() {
              _selectedIndex = 4; // Updated to point to subscription
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    
    // Check subscription status
    if (!subscriptionProvider.hasActiveSubscription && _selectedIndex != 0 && _selectedIndex != 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 4; // Redirect to subscription screen
        });
      });
    }

    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          const NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Sales',
          ),
          const NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          // Only show subscription tab if not subscribed
          if (!subscriptionProvider.hasActiveSubscription)
            const NavigationDestination(
              icon: Icon(Icons.card_membership_outlined),
              selectedIcon: Icon(Icons.card_membership),
              label: 'Subscription',
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!subscriptionProvider.hasActiveSubscription) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Active subscription required'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  setState(() {
                    _selectedIndex = 4;
                  });
                  return;
                }
                
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewSaleScreen()),
                );
              },
              label: const Text('New Sale'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class DashboardHome extends StatefulWidget {
  final VoidCallback onNavigateToSubscription;
  
  const DashboardHome({super.key, required this.onNavigateToSubscription});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    // Reload user to get latest email verification status
    _reloadUser();
  }

  Future<void> _reloadUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.reloadUser();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);

    final currencyFormatter = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await inventoryProvider.loadStats();
          await salesProvider.loadStats();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email Verification Banner
              if (authProvider.user != null && !authProvider.user!.emailVerified)
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.mail_outline, color: Colors.amber.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please Verify Your Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a verification link to ${authProvider.user!.email}',
                          style: TextStyle(color: Colors.amber.shade800),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await authProvider.sendEmailVerification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Verification email sent!'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Resend Verification Email'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (authProvider.user != null && !authProvider.user!.emailVerified)
                const SizedBox(height: 16),

              // Subscription Status Card
              if (!subscriptionProvider.hasActiveSubscription)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Subscription Required',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToSubscription,
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),

              // Stats Cards
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    title: 'Total Items',
                    value: '${inventoryProvider.stats['totalItems'] ?? 0}',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Total Sales',
                    value: '${salesProvider.stats['totalSales'] ?? 0}',
                    icon: Icons.receipt_long,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Inventory Value',
                    value: currencyFormatter.format(
                      inventoryProvider.stats['totalValue'] ?? 0,
                    ),
                    icon: Icons.attach_money,
                    color: Colors.purple,
                    valueSize: 14,
                  ),
                  _StatCard(
                    title: 'Revenue',
                    value: currencyFormatter.format(
                      salesProvider.stats['totalRevenue'] ?? 0,
                    ),
                    icon: Icons.trending_up,
                    color: Colors.orange,
                    valueSize: 14,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      title: 'New Sale',
                      icon: Icons.add_shopping_cart,
                      color: Colors.green,
                      onTap: () {
                        if (!subscriptionProvider.hasActiveSubscription) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Subscription required')),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewSaleScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      title: 'View Inventory',
                      icon: Icons.list_alt,
                      color: Colors.blue,
                      onTap: () {
                        // Will be handled by bottom nav
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ActionCardFullWidth(
                title: 'Business Reports (P&L)',
                subtitle: 'Daily, Weekly & Monthly summaries',
                icon: Icons.bar_chart_rounded,
                color: Colors.indigo,
                onTap: () {
                  if (!subscriptionProvider.hasActiveSubscription) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Subscription required to view reports')),
                    );
                    widget.onNavigateToSubscription();
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? valueSize;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: valueSize,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCardFullWidth extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCardFullWidth({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
