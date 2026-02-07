import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/entities/auth.dart'; // Add this import
import 'package:restaurant_mobile_app/domain/repositories/auth_repository.dart';

abstract class AuthUseCase<T, Params> {
  Future<Result<T>> execute(Params params);
}

class LoginUseCase implements AuthUseCase<User, AuthCredentials> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(AuthCredentials params) async {
    return await _authRepository.login(params);
  }
}

class RegisterUseCase implements AuthUseCase<User, RegisterData> {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(RegisterData params) async {
    return await _authRepository.register(params);
  }
}

class GetCurrentUserUseCase implements AuthUseCase<User, String> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(String params) async {
    return await _authRepository.getCurrentUser(params);
  }
}

class UpdateProfileUseCase implements AuthUseCase<User, UpdateProfileData> {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  @override
  Future<Result<User>> execute(UpdateProfileData params) async {
    final tokenResult = await _authRepository.getStoredToken();
    return await tokenResult.fold(
      onSuccess: (token) async {
        return await _authRepository.updateProfile(params.updates, token);
      },
      onFailure: (failure) => ResultFailure(failure),
    );
  }
}

class ChangePasswordUseCase implements AuthUseCase<void, ChangePasswordData> {
  final AuthRepository _authRepository;

  ChangePasswordUseCase(this._authRepository);

  @override
  Future<Result<void>> execute(ChangePasswordData params) async {
    final tokenResult = await _authRepository.getStoredToken();
    return await tokenResult.fold(
      onSuccess: (token) async {
        return await _authRepository.changePassword(params, token);
      },
      onFailure: (failure) => ResultFailure(failure),
    );
  }
}

class LogoutUseCase implements AuthUseCase<void, void> {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<Result<void>> execute([void params]) async {
    return await _authRepository.logout();
  }
}

// Data classes for use cases
class UpdateProfileData {
  final Map<String, dynamic> updates;

  UpdateProfileData(this.updates);
}
