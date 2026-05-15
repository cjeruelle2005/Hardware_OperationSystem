import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/routes/app_router.dart';

/// Settings screen with logout functionality
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              subtitle: const Text('Sign out of your account'),
              onTap: () async {
                await authNotifier.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
