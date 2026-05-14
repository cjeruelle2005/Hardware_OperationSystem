import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/utils/env_config.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(url: EnvConfig.supabaseUrl, anonKey: EnvConfig.supabaseAnonKey);
    print("✅ Supabase Connected");
  } catch (e) {
    print("❌ Supabase Error: $e");
  }
  runApp(const ProviderScope(child: HardwareOSApp()));
}

class HardwareOSApp extends ConsumerWidget {
  const HardwareOSApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'HardwareOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System Ready"), backgroundColor: Color(0xFF22C55E)),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary, width: 2)),
              child: const Icon(Icons.build_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('HardwareOS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Operational Infrastructure', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
