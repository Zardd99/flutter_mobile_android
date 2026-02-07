import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_mobile_app/domain/entities/auth.dart';

class AuthManager extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  bool _isInitialized = false;

  AuthManager({required AuthRepository authRepository})
    : _authRepository = authRepository;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final tokenResult = await _authRepository.getStoredToken();
    await tokenResult.fold(
      onSuccess: (token) async {
        _token = token;
        if (token.isNotEmpty) {
          final userResult = await _authRepository.getCurrentUser(token);
          userResult.fold(
            onSuccess: (user) {
              _currentUser = user;
              _isAuthenticated = true;
              _error = null;
            },
            onFailure: (failure) {
              _currentUser = null;
              _isAuthenticated = false;
              _error = failure.message;
            },
          );
        } else {
          _currentUser = null;
          _isAuthenticated = false;
        }
      },
      onFailure: (failure) {
        _currentUser = null;
        _isAuthenticated = false;
        _error = failure.message;
      },
    );

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<Result<User>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final credentials = AuthCredentials(email: email, password: password);
    final result = await _authRepository.login(credentials);

    result.fold(
      onSuccess: (user) async {
        _currentUser = user;
        _isAuthenticated = true;
        _error = null;

        // Update token
        final tokenResult = await _authRepository.getStoredToken();
        tokenResult.fold(
          onSuccess: (token) {
            _token = token;
          },
          onFailure: (_) {},
        );
      },
      onFailure: (failure) {
        _currentUser = null;
        _isAuthenticated = false;
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Result<User>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final registerData = RegisterData(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    final result = await _authRepository.register(registerData);

    result.fold(
      onSuccess: (user) async {
        _currentUser = user;
        _isAuthenticated = true;
        _error = null;

        // Update token
        final tokenResult = await _authRepository.getStoredToken();
        tokenResult.fold(
          onSuccess: (token) {
            _token = token;
          },
          onFailure: (_) {},
        );
      },
      onFailure: (failure) {
        _currentUser = null;
        _isAuthenticated = false;
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Result<User>> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final tokenResult = await _authRepository.getStoredToken();
    return await tokenResult.fold(
      onSuccess: (token) async {
        if (token.isEmpty) {
          return ResultFailure(AuthenticationFailure('Not authenticated'));
        }

        final result = await _authRepository.updateProfile(updates, token);

        result.fold(
          onSuccess: (user) {
            _currentUser = user;
            _error = null;
          },
          onFailure: (failure) {
            _error = failure.message;
          },
        );

        _isLoading = false;
        notifyListeners();
        return result;
      },
      onFailure: (failure) {
        _isLoading = false;
        notifyListeners();
        return ResultFailure(failure);
      },
    );
  }

  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final tokenResult = await _authRepository.getStoredToken();
    return await tokenResult.fold(
      onSuccess: (token) async {
        if (token.isEmpty) {
          return ResultFailure(AuthenticationFailure('Not authenticated'));
        }

        final changePasswordData = ChangePasswordData(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        final result = await _authRepository.changePassword(
          changePasswordData,
          token,
        );

        result.fold(
          onSuccess: (_) {
            _error = null;
          },
          onFailure: (failure) {
            _error = failure.message;
          },
        );

        _isLoading = false;
        notifyListeners();
        return result;
      },
      onFailure: (failure) {
        _isLoading = false;
        notifyListeners();
        return ResultFailure(failure);
      },
    );
  }

  Future<Result<String>> getToken() async {
    return await _authRepository.getStoredToken();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();

    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    _error = null;
    _isLoading = false;

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
