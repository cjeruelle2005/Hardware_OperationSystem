// Error handling - Failures for functional error handling with dartz

import 'package:equatable/equatable.dart';

/// Base failure class for functional error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(message: 'Invalid email or password', code: 'INVALID_CREDENTIALS');
}

class AuthNotFoundFailure extends AuthFailure {
  const AuthNotFoundFailure()
      : super(message: 'User not found', code: 'USER_NOT_FOUND');
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure()
      : super(message: 'Session expired. Please login again.', code: 'SESSION_EXPIRED');
}

// Tenant failures
class TenantFailure extends Failure {
  const TenantFailure({
    required super.message,
    super.code,
  });
}

class TenantNotFoundFailure extends TenantFailure {
  const TenantNotFoundFailure()
      : super(message: 'Tenant not found', code: 'TENANT_NOT_FOUND');
}

class TenantInactiveFailure extends TenantFailure {
  const TenantInactiveFailure()
      : super(message: 'This account is inactive. Please contact support.', code: 'TENANT_INACTIVE');
}

class NoTenantAccessFailure extends TenantFailure {
  const NoTenantAccessFailure()
      : super(message: 'You do not have access to this tenant', code: 'NO_TENANT_ACCESS');
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

class NoConnectionFailure extends NetworkFailure {
  const NoConnectionFailure()
      : super(message: 'No internet connection. Changes will sync when online.', code: 'NO_CONNECTION');
}

class ServerFailure extends NetworkFailure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure()
      : super(message: 'Request timed out. Please try again.', code: 'TIMEOUT');
}

// Data failures
class DataFailure extends Failure {
  const DataFailure({
    required super.message,
    super.code,
  });
}

class ValidationFailure extends DataFailure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

class DuplicateRecordFailure extends DataFailure {
  const DuplicateRecordFailure(String field)
      : super(message: 'A record with this $field already exists', code: 'DUPLICATE_RECORD');
}

class NotFoundFailure extends DataFailure {
  const NotFoundFailure(String entity)
      : super(message: '$entity not found', code: 'NOT_FOUND');
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

class UnauthorizedFailure extends PermissionFailure {
  const UnauthorizedFailure()
      : super(message: 'You do not have permission to perform this action', code: 'UNAUTHORIZED');
}

class ForbiddenFailure extends PermissionFailure {
  const ForbiddenFailure()
      : super(message: 'Access forbidden', code: 'FORBIDDEN');
}

// Sync failures
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
  });
}

class SyncConflictFailure extends SyncFailure {
  const SyncConflictFailure()
      : super(message: 'Data conflict detected. Manual resolution required.', code: 'SYNC_CONFLICT');
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

// Unknown failures (fallback)
class UnknownFailure extends Failure {
  const UnknownFailure([String? message])
      : super(
          message: message ?? 'An unexpected error occurred. Please try again.',
          code: 'UNKNOWN',
        );
}
