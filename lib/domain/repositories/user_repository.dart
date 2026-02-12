// lib/domain/repositories/user_repository.dart
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';

/// Contract for user management data operations.
///
/// This repository abstracts the data source for user entities and is used
/// by the domain layer (use cases) to retrieve and manipulate user data.
/// All methods return [Result] to handle success/failure explicitly.
abstract class UserRepository {
  /// Retrieves a list of all users.
  ///
  /// [token] – authentication token required for admin access.
  Future<Result<List<User>>> getUsers(String token);

  /// Retrieves a single user by their unique identifier.
  ///
  /// [id]    – the user's ID.
  /// [token] – authentication token.
  Future<Result<User>> getUserById(String id, String token);

  /// Updates an existing user's information.
  ///
  /// [id]     – the user's ID.
  /// [data]   – a map containing the fields to update.
  /// [token]  – authentication token.
  Future<Result<User>> updateUser(
    String id,
    Map<String, dynamic> data,
    String token,
  );

  /// Deletes (or deactivates) a user.
  ///
  /// [id]    – the user's ID.
  /// [token] – authentication token.
  Future<Result<void>> deleteUser(String id, String token);
}
