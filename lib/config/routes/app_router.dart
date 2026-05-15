import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/inventory/presentation/screens/inventory_list_screen.dart';
import '../features/warehouse/presentation/screens/warehouse_screen.dart';
import '../features/procurement/presentation/screens/procurement_screen.dart';
import '../features/quotations/presentation/screens/quotations_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// App router configuration using GoRouter
/// 
/// Handles navigation with authentication guards and tenant isolation
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Redirect to dashboard if authenticated and trying to access auth pages
      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      // Redirect to login if not authenticated and trying to access protected routes
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      return null;
    },
    routes: [
      // ==================== AUTH ROUTES ====================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ==================== MAIN APP ROUTES ====================
      ShellRoute(
        builder: (context, state, child) {
          // Main app shell with sidebar/navigation
          return DashboardShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'inventory_detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return InventoryDetailScreen(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/warehouse',
            name: 'warehouse',
            builder: (context, state) => const WarehouseScreen(),
          ),
          GoRoute(
            path: '/procurement',
            name: 'procurement',
            builder: (context, state) => const ProcurementScreen(),
          ),
          GoRoute(
            path: '/quotations',
            name: 'quotations',
            builder: (context, state) => const QuotationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Dashboard shell widget with sidebar navigation
class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Inventory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warehouse_outlined),
                selectedIcon: Icon(Icons.warehouse),
                label: Text('Warehouse'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Procurement'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Quotations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: _getSelectedIndex(context),
            onDestinationSelected: (index) => _onDestinationSelected(context, index),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/dashboard')) return 0;
    if (location.contains('/inventory')) return 1;
    if (location.contains('/warehouse')) return 2;
    if (location.contains('/procurement')) return 3;
    if (location.contains('/quotations')) return 4;
    if (location.contains('/settings')) return 5;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/inventory');
        break;
      case 2:
        context.go('/warehouse');
        break;
      case 3:
        context.go('/procurement');
        break;
      case 4:
        context.go('/quotations');
        break;
      case 5:
        context.go('/settings');
        break;
    }
  }
}

// Placeholder screen classes (to be implemented in feature modules)
class InventoryDetailScreen extends StatelessWidget {
  final String productId;

  const InventoryDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: Center(child: Text('Product ID: $productId')),
    );
  }
}
