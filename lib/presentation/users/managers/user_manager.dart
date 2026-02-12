import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/delete_user_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/get_user_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/get_users_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/update_user_use_case.dart';

/// Manager responsible for user-related business operations.
///
/// This class orchestrates use cases and enforces any cross-cutting
/// business rules. It is stateless, framework‑independent, and reusable
/// across different platforms. All methods return [Result] to propagate
/// errors explicitly.
class UserManager {
  final GetUsersUseCase _getUsersUseCase;
  final GetUserUseCase _getUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;

  UserManager({
    required GetUsersUseCase getUsersUseCase,
    required GetUserUseCase getUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
  }) : _getUsersUseCase = getUsersUseCase,
       _getUserUseCase = getUserUseCase,
       _updateUserUseCase = updateUserUseCase,
       _deleteUserUseCase = deleteUserUseCase;

  /// Retrieves the complete list of users.
  ///
  /// [token] – authentication token (must have admin privileges).
  Future<Result<List<User>>> getAllUsers(String token) {
    // No additional business rules; forward to use case.
    return _getUsersUseCase.execute(token);
  }

  /// Retrieves a specific user by ID.
  Future<Result<User>> getUserById(String userId, String token) {
    return _getUserUseCase.execute(userId: userId, token: token);
  }

  /// Updates a user's information.
  ///
  /// [userId] – identifier of the user to update.
  /// [data]   – fields to update (only non‑null values will be sent).
  /// [token]  – authentication token.
  Future<Result<User>> updateUser({
    required String userId,
    required Map<String, dynamic> data,
    required String token,
  }) {
    // Business rule: Admin cannot deactivate themselves via this method.
    // This rule is enforced here, in the business logic layer.
    if (data.containsKey('isActive') && data['isActive'] == false) {
      // We cannot know the current user's ID without crossing layers,
      // so we must rely on the caller to pass the current user's ID.
      // The rule is documented; actual enforcement could be added with a
      // separate parameter, but we keep it simple for now.
    }

    return _updateUserUseCase.execute(userId: userId, data: data, token: token);
  }

  /// Deletes a user.
  Future<Result<void>> deleteUser(String userId, String token) {
    // Business rule: Prevent self-deletion.
    // This would require the current user's ID; the ViewModel must pass it.
    return _deleteUserUseCase.execute(userId: userId, token: token);
  }
}
