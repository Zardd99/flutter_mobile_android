import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/user_repository.dart';

/// Use case for updating an existing user's information.
class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  /// Executes the update with the provided user ID, update data, and token.
  ///
  /// Only fields present in [data] will be updated; omitted fields remain unchanged.
  Future<Result<User>> execute({
    required String userId,
    required Map<String, dynamic> data,
    required String token,
  }) {
    return _repository.updateUser(userId, data, token);
  }
}
