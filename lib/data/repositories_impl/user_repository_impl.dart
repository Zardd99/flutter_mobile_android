// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/data/repositories/user_repository_impl.dart
// Description: Implementation of the user repository.
//              Handles all user management operations (admin only)
//              by communicating with the remote API.
// *****************************************************************************

import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/user_repository.dart';

/// Concrete implementation of [UserRepository].
///
/// This class is responsible for fetching, updating, and deleting user data
/// from the backend API. It is typically used by administrative features
/// and requires elevated privileges (authentication token with admin role).
///
/// All methods return a [Result] type that either contains the requested
/// data or a [Failure]. The raw JSON responses from the remote data source
/// are transformed into [User] domain entities.
class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remoteDataSource;

  /// Creates an instance of [UserRepositoryImpl] with the required remote data source.
  ///
  /// [remoteDataSource] – performs actual HTTP requests to the user management endpoints.
  UserRepositoryImpl(this._remoteDataSource);

  // -------------------------------------------------------------------------
  // USER RETRIEVAL OPERATIONS
  // -------------------------------------------------------------------------

  /// Fetches a list of all registered users.
  ///
  /// [token] – valid authentication token with admin privileges.
  ///
  /// Returns a [Result] containing a [List<User>] on success,
  /// or a [Failure] (e.g., unauthorized, network error) on failure.
  @override
  Future<Result<List<User>>> getUsers(String token) async {
    final result = await _remoteDataSource.getAllUsers(token);
    return result.map((list) {
      return list
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Fetches a single user by their unique identifier.
  ///
  /// [id]    – the user's UUID.
  /// [token] – authentication token (admin or possibly the user themselves).
  ///
  /// Returns a [Result] containing the [User] entity, or a [Failure]
  /// if the user does not exist or access is denied.
  @override
  Future<Result<User>> getUserById(String id, String token) async {
    final result = await _remoteDataSource.getUserById(id, token);
    return result.map((json) => User.fromJson(json));
  }

  // -------------------------------------------------------------------------
  // USER MODIFICATION OPERATIONS
  // -------------------------------------------------------------------------

  /// Updates an existing user's information.
  ///
  /// [id]    – the UUID of the user to update.
  /// [data]  – a map containing the fields to modify (e.g., name, role, isActive).
  /// [token] – authentication token with appropriate permissions.
  ///
  /// Returns the updated [User] entity on success, or a [Failure] on error.
  @override
  Future<Result<User>> updateUser(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final result = await _remoteDataSource.updateUser(id, data, token);
    return result.map((json) => User.fromJson(json));
  }

  /// Permanently deletes a user from the system.
  ///
  /// [id]    – the UUID of the user to delete.
  /// [token] – authentication token with admin privileges.
  ///
  /// On success, returns an empty [Result] (void). The API's response body
  /// (if any) is discarded. On failure, returns a [Failure].
  @override
  Future<Result<void>> deleteUser(String id, String token) async {
    final result = await _remoteDataSource.deleteUser(id, token);
    // Map successful response to a void Success; discard any response data.
    return result.map((_) => Success(null));
  }
}
