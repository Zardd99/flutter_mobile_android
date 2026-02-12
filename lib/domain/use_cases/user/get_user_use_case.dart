import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/user_repository.dart';

/// Use case for fetching a single user by ID.
class GetUserUseCase {
  final UserRepository _repository;

  GetUserUseCase(this._repository);

  Future<Result<User>> execute({
    required String userId,
    required String token,
  }) {
    return _repository.getUserById(userId, token);
  }
}
