// Core result wrapper used across the app to handle success/failure
import 'package:restaurant_mobile_app/core/errors/result.dart';

// Domain entity representing the authenticated user
import 'package:restaurant_mobile_app/domain/entities/user.dart';

// Domain entity holding authentication-related input data
import 'package:restaurant_mobile_app/domain/entities/auth.dart';

// Contract that defines all authentication-related data operations
import 'package:restaurant_mobile_app/domain/repositories/auth_repository.dart';

/// Base abstraction for all authentication-related use cases.
///
/// - Enforces a consistent `execute` method signature
/// - Promotes Clean Architecture by decoupling UI from business logic
/// - Generic over return type [T] and input parameters [Params]
abstract class AuthUseCase<T, Params> {
  Future<Result<T>> execute(Params params);
}

/// Use case responsible for handling user login logic.
///
/// - Delegates actual login implementation to [AuthRepository]
/// - Returns a [Result<User>] to safely propagate success or failure
class LoginUseCase implements AuthUseCase<User, AuthCredentials> {
  final AuthRepository _authRepository;

  // Repository is injected to support dependency inversion & testability
  LoginUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(AuthCredentials params) async {
    // Directly forward credentials to repository
    return await _authRepository.login(params);
  }
}

/// Use case responsible for handling new user registration.
///
/// - Acts as an application-layer boundary
/// - Keeps UI unaware of data source details
class RegisterUseCase implements AuthUseCase<User, RegisterData> {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(RegisterData params) async {
    // Delegates registration process to repository
    return await _authRepository.register(params);
  }
}

/// Use case for retrieving the currently authenticated user.
///
/// - Typically used on app startup or token-based session restore
/// - Accepts a token or identifier as input
class GetCurrentUserUseCase implements AuthUseCase<User, String> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(String params) async {
    // Fetch user details using provided identifier (e.g., token)
    return await _authRepository.getCurrentUser(params);
  }
}

/// Use case responsible for updating the user's profile.
///
/// - Secure operation: requires a valid stored authentication token
/// - Demonstrates proper failure propagation using Result.fold
class UpdateProfileUseCase implements AuthUseCase<User, UpdateProfileData> {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(UpdateProfileData params) async {
    // First retrieve stored authentication token
    final tokenResult = await _authRepository.getStoredToken();

    // Handle both success and failure paths explicitly
    return await tokenResult.fold(
      onSuccess: (token) async {
        // Proceed with profile update using secure token
        return await _authRepository.updateProfile(params.updates, token);
      },
      onFailure: (failure) =>
          // Propagate failure without swallowing or transforming it
          ResultFailure(failure),
    );
  }
}

/// Use case for changing the user's password.
///
/// - Requires authentication token
/// - Keeps sensitive logic out of UI layer
class ChangePasswordUseCase implements AuthUseCase<void, ChangePasswordData> {
  final AuthRepository _authRepository;

  ChangePasswordUseCase(this._authRepository);

  @override
  Future<Result<void>> execute(ChangePasswordData params) async {
    // Retrieve stored token before performing secure operation
    final tokenResult = await _authRepository.getStoredToken();

    return await tokenResult.fold(
      onSuccess: (token) async {
        // Delegate password change to repository
        return await _authRepository.changePassword(params, token);
      },
      onFailure: (failure) =>
          // Explicitly return failure Result
          ResultFailure(failure),
    );
  }
}

/// Use case responsible for logging the user out.
///
/// - Clears authentication state
/// - No parameters required
class LogoutUseCase implements AuthUseCase<void, void> {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<Result<void>> execute([void params]) async {
    // Invalidate session and clear stored credentials
    return await _authRepository.logout();
  }
}

/// Data holder for profile update operations.
///
/// - Encapsulates update payload
/// - Prevents leaking raw Map usage across layers
class UpdateProfileData {
  final Map<String, dynamic> updates;

  UpdateProfileData(this.updates);
}
