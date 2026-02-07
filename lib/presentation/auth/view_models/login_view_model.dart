import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/auth.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/domain/use_cases/auth_use_cases.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  bool _isLoading = false;
  User? _currentUser;

  LoginViewModel(this._loginUseCase);

  // State
  String _email = '';
  String? _error;
  String _password = '';
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  // Getters
  String get email => _email;
  String get password => _password;
  String? get errorMessage => _errorMessage;

  // Setters
  void setEmail(String value) {
    _email = value.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _errorMessage = null;
    notifyListeners();
  }

  // Validation
  bool get isValid {
    return _email.isNotEmpty && _password.isNotEmpty;
  }

  String? validateEmail() {
    if (_email.isEmpty) return 'Email is required';

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(_email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePassword() {
    if (_password.isEmpty) return 'Password is required';
    if (_password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Actions
  Future<Result<User>> login() async {
    final emailError = validateEmail();
    final passwordError = validatePassword();

    if (emailError != null || passwordError != null) {
      return ResultFailure(
        ValidationFailure(emailError ?? passwordError ?? 'Validation failed'),
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _loginUseCase.execute(
        AuthCredentials(email: email, password: password),
      );

      _isLoading = false;

      if (result.isSuccess) {
        _currentUser = result.valueOrNull;
        notifyListeners();
      } else {
        _errorMessage = result.failureOrNull?.message;
        notifyListeners();
      }

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();

      return ResultFailure(GenericFailure('Login failed: $e'));
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _email = '';
    _password = '';
    _isLoading = false;
    _errorMessage = null;
    _currentUser = null;
    notifyListeners();
  }
}
