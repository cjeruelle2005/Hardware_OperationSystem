import 'package:envied/envied.dart';
part 'env_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class EnvConfig {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _EnvConfig.supabaseUrl;
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _EnvConfig.supabaseAnonKey;
}
