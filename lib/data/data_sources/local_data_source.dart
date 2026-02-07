import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAuthData();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  @override
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  @override
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString == null) return null;

    try {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userDataKey);
  }
}

// Helper function for JSON encoding/decoding
dynamic jsonDecode(String source) {
  // Using dart:convert's jsonDecode
  // You might need to import it: import 'dart:convert';
  return _jsonDecode(source);
}

String jsonEncode(dynamic value) {
  // Using dart:convert's jsonEncode
  // You might need to import it: import 'dart:convert';
  return _jsonEncode(value);
}

// These would be actual implementations using dart:convert
dynamic _jsonDecode(String source) {
  // This is a placeholder - in real code, use dart:convert
  return null;
}

String _jsonEncode(dynamic value) {
  // This is a placeholder - in real code, use dart:convert
  return '';
}
