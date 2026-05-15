/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class NoInternetException extends NetworkException {
  const NoInternetException()
      : super('No internet connection', code: 'NO_INTERNET');
}

class TimeoutException extends NetworkException {
  const TimeoutException()
      : super('Request timed out', code: 'TIMEOUT');
}

class ServerException extends NetworkException {
  const ServerException(
    super.message, {
    super.code = 'SERVER_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException()
      : super('Unauthorized access', code: 'UNAUTHORIZED');
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super('Session expired', code: 'SESSION_EXPIRED');
}

/// Tenant-related exceptions
class TenantException extends AppException {
  const TenantException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class TenantNotFoundException extends TenantException {
  const TenantNotFoundException(String tenantId)
      : super('Tenant not found: $tenantId', code: 'TENANT_NOT_FOUND');
}

class TenantInactiveException extends TenantException {
  const TenantInactiveException()
      : super('Tenant account is inactive', code: 'TENANT_INACTIVE');
}

/// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class SyncException extends DatabaseException {
  const SyncException(
    super.message, {
    super.code = 'SYNC_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

/// Permission exceptions
class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String? feature])
      : super(
          feature != null
              ? 'Permission denied: $feature'
              : 'Permission denied',
          code: 'PERMISSION_DENIED',
        );
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code = 'CACHE_ERROR',
    super.originalError,
    super.stackTrace,
  });
}
