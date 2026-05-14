// Main entry point for HardwareOS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services here (before runApp)
  // await initializeServices();

  runApp(
    const ProviderScope(
      child: HardwareOSApp(),
    ),
  );
}

class HardwareOSApp extends ConsumerWidget {
  const HardwareOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch router provider (to be implemented)
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HardwareOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Industrial apps typically use light theme
      routerConfig: router,
    );
  }
}
