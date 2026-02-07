import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/local_data_source.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/auth.dart'; // Add this
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

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

  @override
  Future<Result<User>> getCurrentUser(String token) async {
    final result = await _remoteDataSource.getCurrentUser(token);
    return result.map((userData) => User.fromJson(userData));
  }

  @override
  Future<Result<User>> updateProfile(
    Map<String, dynamic> updates,
    String token,
  ) async {
    final result = await _remoteDataSource.updateProfile(updates, token);
    return result.map((userData) => User.fromJson(userData));
  }

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

  @override
  Future<Result<void>> logout() async {
    await _localDataSource.clearAuthData();
    return Success(null);
  }

  @override
  Future<Result<String>> getStoredToken() async {
    final token = await _localDataSource.getAuthToken();
    if (token != null) {
      return Success(token);
    }
    return ResultFailure(AuthenticationFailure('No token found'));
  }

  @override
  Future<Result<void>> saveToken(String token) async {
    await _localDataSource.saveAuthToken(token);
    return Success(null);
  }

  @override
  Future<Result<void>> clearToken() async {
    await _localDataSource.clearAuthData();
    return Success(null);
  }
}
