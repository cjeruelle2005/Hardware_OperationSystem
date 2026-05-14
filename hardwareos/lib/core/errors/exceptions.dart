// Error handling - Custom exceptions

/// Base exception for all application errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
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

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super(message: 'Invalid email or password', code: 'INVALID_CREDENTIALS');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super(message: 'User not found', code: 'USER_NOT_FOUND');
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super(message: 'Session expired. Please login again.', code: 'SESSION_EXPIRED');
}

/// Tenant exceptions
class TenantException extends AppException {
  const TenantException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class TenantNotFoundException extends TenantException {
  const TenantNotFoundException()
      : super(message: 'Tenant not found', code: 'TENANT_NOT_FOUND');
}

class TenantInactiveException extends TenantException {
  const TenantInactiveException()
      : super(message: 'This account is inactive. Please contact support.', code: 'TENANT_INACTIVE');
}

class NoTenantAccessException extends TenantException {
  const NoTenantAccessException()
      : super(message: 'You do not have access to this tenant', code: 'NO_TENANT_ACCESS');
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class NoConnectionException extends NetworkException {
  const NoConnectionException()
      : super(message: 'No internet connection. Changes will sync when online.', code: 'NO_CONNECTION');
}

class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class TimeoutException extends NetworkException {
  const TimeoutException()
      : super(message: 'Request timed out. Please try again.', code: 'TIMEOUT');
}

/// Data exceptions
class DataException extends AppException {
  const DataException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationException extends DataException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    super.stackTrace,
  });
}

class DuplicateRecordException extends DataException {
  const DuplicateRecordException(String field)
      : super(message: 'A record with this $field already exists', code: 'DUPLICATE_RECORD');
}

class NotFoundException extends DataException {
  const NotFoundException(String entity)
      : super(message: '$entity not found', code: 'NOT_FOUND');
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class UnauthorizedException extends PermissionException {
  const UnauthorizedException()
      : super(message: 'You do not have permission to perform this action', code: 'UNAUTHORIZED');
}

class ForbiddenException extends PermissionException {
  const ForbiddenException()
      : super(message: 'Access forbidden', code: 'FORBIDDEN');
}

/// Sync exceptions
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class SyncConflictException extends SyncException {
  const SyncConflictException()
      : super(message: 'Data conflict detected. Manual resolution required.', code: 'SYNC_CONFLICT');
}
