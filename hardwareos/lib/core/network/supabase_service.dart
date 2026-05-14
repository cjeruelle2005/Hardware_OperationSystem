// Network - Supabase client wrapper for HardwareOS

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  /// Initialize Supabase client
  void initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) {
    if (_isInitialized) return;

    Supabase.instance.connect(
      supabaseUrl,
      supabaseAnonKey,
    );

    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client?.auth.currentUser != null;

  /// Get current user
  User? get currentUser => _client?.auth.currentUser;

  /// Get current session
  AuthSession? get currentSession => _client?.auth.currentSession;

  /// Set tenant context for RLS policies
  /// This should be called after login and when switching tenants
  Future<void> setTenantContext(String tenantId) async {
    // Note: Supabase doesn't directly support custom claims in JWT
    // We'll store tenant_id in local state and pass it with queries
    // For advanced RLS, you'd need to use Supabase Edge Functions
  }

  /// Clear tenant context (on logout)
  void clearTenantContext() {
    // Clear any cached tenant information
  }

  /// Sign out
  Future<void> signOut() async {
    await _client?.auth.signOut();
    clearTenantContext();
    _isInitialized = false;
    _client = null;
  }

  /// Stream of auth state changes
  Stream<AuthState> get onAuthStateChanges => 
      _client?.auth.onAuthStateChanges ?? const Stream.empty();
}

// Helper extension for Supabase queries with tenant isolation
extension TenantQuery on PostgrestFilterBuilder {
  /// Add tenant_id filter to query for multi-tenant isolation
  PostgrestFilterBuilder withTenant(String tenantId) {
    return eq('tenant_id', tenantId);
  }
}
