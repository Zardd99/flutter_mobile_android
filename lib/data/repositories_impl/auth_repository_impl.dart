// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/data/repositories/auth_repository_impl.dart
// Description: Implementation of the authentication repository.
//              Handles all authentication-related operations by coordinating
//              remote and local data sources.
// *****************************************************************************

import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/local_data_source.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/auth.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// This class bridges the domain layer with the data layer by:
///   - Calling remote APIs via [RemoteDataSource] for authentication operations.
///   - Persisting and retrieving authentication data via [LocalDataSource].
///
/// All methods return a [Result] type, encapsulating either a success value
/// or a [Failure] object. Network or local errors are propagated as failures.
class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  /// Creates an instance of [AuthRepositoryImpl] with required dependencies.
  ///
  /// [remoteDataSource] – handles all HTTP requests to the backend API.
  /// [localDataSource] – handles local storage (secure storage, shared prefs).
  AuthRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  // -------------------------------------------------------------------------
  // AUTHENTICATION OPERATIONS
  // -------------------------------------------------------------------------

  /// Authenticates a user with email and password.
  ///
  /// Steps:
  /// 1. Sends login credentials to the remote API.
  /// 2. On success, extracts the authentication token and user data.
  /// 3. Persists the token and user data locally.
  /// 4. Returns a [User] entity.
  ///
  /// On failure, propagates the [Failure] from the remote data source.
  @override
  Future<Result<User>> login(AuthCredentials credentials) async {
    final result = await _remoteDataSource.login({
      'email': credentials.email,
      'password': credentials.password,
    });

    return result.fold(
      onSuccess: (data) async {
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        await _localDataSource.saveAuthToken(token);
        await _localDataSource.saveUserData(userData);

        return Success(User.fromJson(userData));
      },
      onFailure: (failure) => ResultFailure(failure),
    );
  }

  /// Registers a new user account.
  ///
  /// Sends registration data to the remote API. On successful registration,
  /// the API returns an authentication token and the new user's data,
  /// which are stored locally before returning the [User] entity.
  ///
  /// Any failure (validation error, network issue, etc.) is returned as a [Failure].
  @override
  Future<Result<User>> register(RegisterData data) async {
    final result = await _remoteDataSource.register({
      'name': data.name,
      'email': data.email,
      'password': data.password,
      'role': data.role,
    });

    return result.fold(
      onSuccess: (responseData) async {
        final token = responseData['token'] as String;
        final userData = responseData['user'] as Map<String, dynamic>;

        await _localDataSource.saveAuthToken(token);
        await _localDataSource.saveUserData(userData);

        return Success(User.fromJson(userData));
      },
      onFailure: (failure) => ResultFailure(failure),
    );
  }

  /// Fetches the profile of the currently authenticated user.
  ///
  /// Requires a valid [token] (Bearer) to authorize the request.
  /// The remote data source returns the raw user data, which is then
  /// transformed into a [User] entity.
  @override
  Future<Result<User>> getCurrentUser(String token) async {
    final result = await _remoteDataSource.getCurrentUser(token);
    return result.map((userData) => User.fromJson(userData));
  }

  /// Updates the current user's profile.
  ///
  /// [updates] – a map of fields to modify (e.g., name, email, avatar).
  /// [token]   – valid authentication token.
  ///
  /// Returns the updated [User] entity after successful API call.
  @override
  Future<Result<User>> updateProfile(
    Map<String, dynamic> updates,
    String token,
  ) async {
    final result = await _remoteDataSource.updateProfile(updates, token);
    return result.map((userData) => User.fromJson(userData));
  }

  /// Changes the user's password.
  ///
  /// [data]  – contains the current and new password.
  /// [token] – authentication token.
  ///
  /// On success, returns an empty [Result] (void). Any failure (e.g.,
  /// incorrect current password) is returned as a [Failure].
  @override
  Future<Result<void>> changePassword(
    ChangePasswordData data,
    String token,
  ) async {
    final result = await _remoteDataSource.changePassword({
      'currentPassword': data.currentPassword,
      'newPassword': data.newPassword,
    }, token);
    return result.map((_) {});
  }

  /// Logs out the current user by clearing all locally stored authentication data.
  ///
  /// This method does not call a remote logout endpoint; it only removes
  /// the token and user information from local storage.
  @override
  Future<Result<void>> logout() async {
    await _localDataSource.clearAuthData();
    return Success(null);
  }

  // -------------------------------------------------------------------------
  // TOKEN MANAGEMENT (LOCAL)
  // -------------------------------------------------------------------------

  /// Retrieves the stored authentication token from local storage.
  ///
  /// Returns a [Success] containing the token string if it exists,
  /// otherwise an [AuthenticationFailure] indicating that no token was found.
  @override
  Future<Result<String>> getStoredToken() async {
    final token = await _localDataSource.getAuthToken();
    if (token != null) {
      return Success(token);
    }
    return ResultFailure(AuthenticationFailure('No token found'));
  }

  /// Persists an authentication token to local storage.
  ///
  /// Typically called after a successful login or registration.
  @override
  Future<Result<void>> saveToken(String token) async {
    await _localDataSource.saveAuthToken(token);
    return Success(null);
  }

  /// Removes any stored authentication token and user data from local storage.
  ///
  /// This is used during logout or when a token becomes invalid/expired.
  @override
  Future<Result<void>> clearToken() async {
    await _localDataSource.clearAuthData();
    return Success(null);
  }
}
