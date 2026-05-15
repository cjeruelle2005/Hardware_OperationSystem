import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service singleton for HardwareOS
/// 
/// Handles all Supabase connections, authentication, and database operations.
/// Implements multi-tenant architecture with tenant_id isolation.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService _instance = SupabaseService._();
  static SupabaseService get instance => _instance;

  late final SupabaseClient _client;
  bool _isInitialized = false;

  /// Check if Supabase is initialized
  bool get isInitialized => _isInitialized;

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  /// Initialize Supabase with environment variables
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Import environment configuration
      // In production, use envied package for type-safe env vars
      const supabaseUrl = String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      );
      const supabaseAnonKey = String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );

      // Fallback to hardcoded values for development (replace with actual values)
      final url = supabaseUrl.isNotEmpty
          ? supabaseUrl
          : 'YOUR_SUPABASE_URL'; // Replace with your Supabase URL
      final anonKey = supabaseAnonKey.isNotEmpty
          ? supabaseAnonKey
          : 'YOUR_SUPABASE_ANON_KEY'; // Replace with your Anon Key

      if (url == 'YOUR_SUPABASE_URL' || anonKey == 'YOUR_SUPABASE_ANON_KEY') {
        print('⚠️  WARNING: Supabase credentials not configured.');
        print('Please set SUPABASE_URL and SUPABASE_ANON_KEY in your .env file');
        print('Then run: flutter pub run build_runner build');
        // Don't throw - allow app to run in demo mode
        _isInitialized = false;
        return;
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true, // Set to false in production
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      print('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Failed to initialize Supabase: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== MULTI-TENANT HELPERS ====================

  /// Get current tenant ID from user session
  String? getCurrentTenantId() {
    if (!_isInitialized) return null;

    final user = _client.auth.currentUser;
    if (user == null) return null;

    // Tenant ID is stored in user metadata or app_metadata
    // This will be set during login/tenant selection
    return user.appMetadata['tenant_id'] as String?;
  }

  /// Set tenant context for the current session
  Future<void> setTenantContext(String tenantId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    // Update user's app_metadata with tenant_id
    // This ensures all subsequent queries include tenant isolation
    await _client.auth.updateUser(
      UserAttributes(
        data: {'tenant_id': tenantId},
      ),
    );
  }

  /// Build tenant-isolated query
  /// Always filter by tenant_id to ensure data isolation
  Map<String, dynamic> buildTenantFilter({String? tenantId}) {
    final currentTenant = tenantId ?? getCurrentTenantId();

    if (currentTenant == null) {
      throw Exception('No tenant context available');
    }

    return {'tenant_id': currentTenant};
  }

  // ==================== AUTHENTICATION ====================

  /// Sign up a new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? tenantId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    final userData = {
      ...?metadata,
      if (tenantId != null) 'tenant_id': tenantId,
    };

    return await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    if (!_isInitialized) return;
    await _client.auth.signOut();
  }

  /// Get current authenticated user
  User? get currentUser {
    if (!_isInitialized) return null;
    return _client.auth.currentUser;
  }

  /// Listen to auth state changes
  Stream<AuthState> get onAuthStateChange {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }
    return _client.auth.onAuthStateChange;
  }

  // ==================== DATABASE OPERATIONS ====================

  /// Insert data with automatic tenant isolation
  Future<PostgrestList> insert({
    required String table,
    required Map<String, dynamic> values,
    String? tenantId,
  }) async {
    final filter = buildTenantFilter(tenantId: tenantId);

    return await _client
        .from(table)
        .insert({...values, ...filter})
        .select()
        .execute()
        .then((response) => response.data);
  }

  /// Query data with automatic tenant isolation
  PostgrestFilterBuilder query(String table, {String? tenantId}) {
    final filter = buildTenantFilter(tenantId: tenantId);

    return _client
        .from(table)
        .select()
        .eq('tenant_id', filter['tenant_id'] as String);
  }

  /// Update data with tenant isolation check
  Future<PostgrestList> update({
    required String table,
    required Map<String, dynamic> values,
    required dynamic id,
    String? tenantId,
  }) async {
    final filter = buildTenantFilter(tenantId: tenantId);

    return await _client
        .from(table)
        .update(values)
        .eq('id', id)
        .eq('tenant_id', filter['tenant_id'] as String)
        .select()
        .execute()
        .then((response) => response.data);
  }

  /// Delete data with tenant isolation check
  Future<void> delete({
    required String table,
    required dynamic id,
    String? tenantId,
  }) async {
    final filter = buildTenantFilter(tenantId: tenantId);

    await _client
        .from(table)
        .delete()
        .eq('id', id)
        .eq('tenant_id', filter['tenant_id'] as String)
        .execute();
  }

  // ==================== REALTIME SUBSCRIPTIONS ====================

  /// Subscribe to realtime changes for a table (tenant-isolated)
  void subscribeToTable({
    required String table,
    required void Function(PostgresAction action) callback,
    String? tenantId,
  }) {
    final filter = buildTenantFilter(tenantId: tenantId);

    _client
        .channel('${table}:${filter['tenant_id']}')
        .onPostgresChanges(
          table: table,
          event: PostgresChangeEvent.all,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tenant_id',
            value: filter['tenant_id'],
          ),
          callback: callback,
        )
        .subscribe();
  }

  // ==================== STORAGE ====================

  /// Upload file to Supabase Storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? tenantId,
  }) async {
    final currentTenant = tenantId ?? getCurrentTenantId();
    final tenantPath = currentTenant != null ? '$currentTenant/$path' : path;

    await _client.storage.from(bucket).uploadBinary(tenantPath, fileBytes);
    return _client.storage.from(bucket).getPublicUrl(tenantPath);
  }

  /// Get file URL from storage
  String getFileUrl({
    required String bucket,
    required String path,
    String? tenantId,
  }) {
    final currentTenant = tenantId ?? getCurrentTenantId();
    final tenantPath = currentTenant != null ? '$currentTenant/$path' : path;

    return _client.storage.from(bucket).getPublicUrl(tenantPath);
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
    String? tenantId,
  }) async {
    final currentTenant = tenantId ?? getCurrentTenantId();
    final tenantPath = currentTenant != null ? '$currentTenant/$path' : path;

    await _client.storage.from(bucket).remove([tenantPath]);
  }
}
