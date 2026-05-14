// Router - GoRouter configuration for HardwareOS

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Route paths
class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String products = '/inventory/products';
  static const String productCreate = '/inventory/products/create';
  static const String productEdit = '/inventory/products/:id/edit';
  static const String categories = '/inventory/categories';
  static const String stockAdjustment = '/inventory/stock/adjust';
  static const String procurement = '/procurement';
  static const String purchaseOrders = '/procurement/purchase-orders';
  static const String suppliers = '/procurement/suppliers';
  static const String sales = '/sales';
  static const String quotations = '/sales/quotations';
  static const String warehouse = '/warehouse';
  static const String settings = '/settings';
  static const String tenantSelect = '/tenant/select';
}

// GoRouter provider (to be used with Riverpod)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const PlaceholderPage(title: 'Login'),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const PlaceholderPage(title: 'Sign Up'),
      ),
      
      // Main App Shell (after authentication)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const PlaceholderPage(title: 'Home'),
        routes: [
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) => const PlaceholderPage(title: 'Dashboard'),
          ),
          
          // Inventory Module
          GoRoute(
            path: 'inventory',
            name: 'inventory',
            builder: (context, state) => const PlaceholderPage(title: 'Inventory'),
            routes: [
              GoRoute(
                path: 'products',
                name: 'products',
                builder: (context, state) => const PlaceholderPage(title: 'Products'),
              ),
              GoRoute(
                path: 'products/create',
                name: 'product-create',
                builder: (context, state) => const PlaceholderPage(title: 'Create Product'),
              ),
              GoRoute(
                path: 'products/:id/edit',
                name: 'product-edit',
                builder: (context, state) => const PlaceholderPage(title: 'Edit Product'),
              ),
              GoRoute(
                path: 'categories',
                name: 'categories',
                builder: (context, state) => const PlaceholderPage(title: 'Categories'),
              ),
              GoRoute(
                path: 'stock/adjust',
                name: 'stock-adjustment',
                builder: (context, state) => const PlaceholderPage(title: 'Stock Adjustment'),
              ),
            ],
          ),
          
          // Procurement Module
          GoRoute(
            path: 'procurement',
            name: 'procurement',
            builder: (context, state) => const PlaceholderPage(title: 'Procurement'),
            routes: [
              GoRoute(
                path: 'purchase-orders',
                name: 'purchase-orders',
                builder: (context, state) => const PlaceholderPage(title: 'Purchase Orders'),
              ),
              GoRoute(
                path: 'suppliers',
                name: 'suppliers',
                builder: (context, state) => const PlaceholderPage(title: 'Suppliers'),
              ),
            ],
          ),
          
          // Sales Module
          GoRoute(
            path: 'sales',
            name: 'sales',
            builder: (context, state) => const PlaceholderPage(title: 'Sales'),
            routes: [
              GoRoute(
                path: 'quotations',
                name: 'quotations',
                builder: (context, state) => const PlaceholderPage(title: 'Quotations'),
              ),
            ],
          ),
          
          // Warehouse Module
          GoRoute(
            path: 'warehouse',
            name: 'warehouse',
            builder: (context, state) => const PlaceholderPage(title: 'Warehouse'),
          ),
          
          // Settings
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const PlaceholderPage(title: 'Settings'),
          ),
        ],
      ),
      
      // Tenant Selection
      GoRoute(
        path: AppRoutes.tenantSelect,
        name: 'tenant-select',
        builder: (context, state) => const PlaceholderPage(title: 'Select Tenant'),
      ),
    ],
    
    // Error page for undefined routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Temporary placeholder page
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '$title - Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This module is under development',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
