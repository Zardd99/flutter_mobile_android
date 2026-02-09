import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/entities/auth.dart';

abstract class AuthRepository {
  // Authentication methods
  Future<Result<User>> login(AuthCredentials credentials);
  Future<Result<User>> register(RegisterData data);
  Future<Result<User>> getCurrentUser(String token);
  Future<Result<User>> updateProfile(
    Map<String, dynamic> updates,
    String token,
  );
  Future<Result<void>> changePassword(ChangePasswordData data, String token);
  Future<Result<void>> logout();

  Future<Result<String>> getStoredToken();
  Future<Result<void>> saveToken(String token);
  Future<Result<void>> clearToken();
}
