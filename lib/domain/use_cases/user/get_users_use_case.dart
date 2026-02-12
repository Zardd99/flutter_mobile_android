import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/user_repository.dart';

/// Use case for retrieving all users.
///
/// This class encapsulates the business logic of fetching the complete
/// list of users. It is stateless and can be safely shared.
class GetUsersUseCase {
  final UserRepository _repository;

  GetUsersUseCase(this._repository);

  /// Executes the use case with the provided authentication token.
  ///
  /// Returns a [Result] containing either a list of [User] entities or a [Failure].
  Future<Result<List<User>>> execute(String token) {
    // The repository call already returns a Result; we simply forward it.
    return _repository.getUsers(token);
  }
}
