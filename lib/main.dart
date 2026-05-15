import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'services/supabase/supabase_service.dart';
import 'providers/auth_provider.dart';

/// Main application entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.instance.initialize();

  runApp(
    const ProviderScope(
      child: HardwareOSApp(),
    ),
  );
}

/// Root application widget
class HardwareOSApp extends ConsumerWidget {
  const HardwareOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'HardwareOS',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Router configuration
      routerConfig: router,
      
      // Localization setup (future)
      localizationsDelegates: const [
        // Add localization delegates here
      ],
      
      // Supported locales (future)
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fil', 'PH'),
      ],
    );
  }
}
