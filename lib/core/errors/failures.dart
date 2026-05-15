/// Base failure class for error handling
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.originalError,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
  });
}

class TenantFailure extends Failure {
  const TenantFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code = 'UNKNOWN',
    super.originalError,
  });
}
