import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/repositories/user_repository.dart';

/// Use case for deleting a user.
class DeleteUserUseCase {
  final UserRepository _repository;

  DeleteUserUseCase(this._repository);

  /// Executes the deletion.
  ///
  /// Returns [Result<void>] indicating success or failure.
  Future<Result<void>> execute({
    required String userId,
    required String token,
  }) {
    return _repository.deleteUser(userId, token);
  }
}
