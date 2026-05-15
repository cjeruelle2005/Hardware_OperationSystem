import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../supabase/supabase_service.dart';

/// Authentication state
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state holder
class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? tenantId;
  final String? role;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.tenantId,
    this.role,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? tenantId,
    String? role,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      error: error ?? this.error,
    );
  }
}

/// Authentication provider using Riverpod
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuthListener();
  }

  final _supabase = SupabaseService.instance;

  /// Initialize auth state listener
  void _initializeAuthListener() {
    if (!_supabase.isInitialized) return;

    // Set initial auth state
    final currentUser = _supabase.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: currentUser.id,
        email: currentUser.email,
        tenantId: _supabase.getCurrentTenantId(),
        role: currentUser.appMetadata['role'] as String?,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Listen to auth state changes
    _supabase.onAuthStateChange.listen((authState) {
      if (authState.session != null) {
        final user = authState.session!.user;
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: user.id,
          email: user.email,
          tenantId: user.appMetadata['tenant_id'] as String?,
          role: user.appMetadata['role'] as String?,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          userId: null,
          email: null,
          tenantId: null,
          role: null,
        );
      }
    });
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, error: null);

      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final tenantId = response.user!.appMetadata['tenant_id'] as String?;
        
        if (tenantId != null) {
          await _supabase.setTenantContext(tenantId);
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: response.user!.id,
          email: response.user!.email,
          tenantId: tenantId,
          role: response.user!.appMetadata['role'] as String?,
        );
      } else {
        throw const AuthException(
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS',
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'An unexpected error occurred. Please try again.',
      );
      rethrow;
    }
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String tenantId,
    String? fullName,
    String? role,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, error: null);

      final response = await _supabase.signUp(
        email: email,
        password: password,
        tenantId: tenantId,
        metadata: {
          if (fullName != null) 'full_name': fullName,
          if (role != null) 'role': role,
        },
      );

      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: response.user!.id,
          email: response.user!.email,
          tenantId: tenantId,
          role: role ?? 'owner',
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to create account. Please try again.',
      );
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to sign out. Please try again.',
      );
      rethrow;
    }
  }

  /// Refresh current user session
  Future<void> refreshUser() async {
    if (!_supabase.isInitialized) return;

    final currentUser = _supabase.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: currentUser.id,
        email: currentUser.email,
        tenantId: _supabase.getCurrentTenantId(),
        role: currentUser.appMetadata['role'] as String?,
      );
    }
  }

  /// Clear error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider to get current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});

/// Provider to get current tenant ID
final currentTenantIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).tenantId;
});

/// Provider to get current user role
final currentUserRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).role;
});

/// Theme mode provider (light/dark)
final themeModeProvider = StateProvider((ref) => ThemeMode.dark);
