abstract class Failure {
  final String message;

  const Failure(this.message);
  factory Failure.network(String message) = NetworkFailure;
  factory Failure.server(String message) = ServerFailure;
  factory Failure.validation(String message) = ValidationFailure;
  factory Failure.authentication(String message) = AuthenticationFailure;
  factory Failure.permission(String message) = PermissionFailure;
  factory Failure.notFound(String message) = NotFoundFailure;
  factory Failure.generic(String message) = GenericFailure;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class GenericFailure extends Failure {
  const GenericFailure(super.message);
}
