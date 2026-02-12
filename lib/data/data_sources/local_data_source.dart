import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract contract for local data persistence.
///
/// Defines operations for storing and retrieving authentication and user data
/// using a local key-value store (e.g., SharedPreferences). All methods are
/// asynchronous to accommodate disk I/O.
abstract class LocalDataSource {
  /// Persists the authentication token.
  ///
  /// [token] - A non‑null string representing the user's authentication token.
  /// Throws an exception if the underlying storage operation fails.
  Future<void> saveAuthToken(String token);

  /// Retrieves the previously stored authentication token.
  ///
  /// Returns the token as a [String] if it exists, otherwise `null`.
  Future<String?> getAuthToken();

  /// Persists the user profile data as a JSON‑encoded string.
  ///
  /// [userData] - A non‑null map containing the user's profile information.
  /// The map is automatically serialised to JSON before storage.
  /// Throws an exception if encoding or storage fails.
  Future<void> saveUserData(Map<String, dynamic> userData);

  /// Retrieves the previously stored user profile data.
  ///
  /// Returns the deserialised [Map] if data exists and is valid JSON,
  /// otherwise `null`. Malformed JSON or any decoding error yields `null`.
  Future<Map<String, dynamic>?> getUserData();

  /// Removes both the authentication token and user data from local storage.
  ///
  /// This effectively clears all session‑related information.
  Future<void> clearAuthData();
}

/// Concrete implementation of [LocalDataSource] using [SharedPreferences].
///
/// All data is stored under predefined string keys. User data is stored as a
/// JSON string to preserve the map structure.
class LocalDataSourceImpl implements LocalDataSource {
  // Key constants – used consistently across all storage operations.
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  @override
  Future<void> saveAuthToken(String token) async {
    // Obtain the SharedPreferences instance (this may be cached by the plugin).
    final prefs = await SharedPreferences.getInstance();
    // Persist the token as a plain string.
    await prefs.setString(_authTokenKey, token);
  }

  @override
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the stored token; returns null if the key does not exist.
    return prefs.getString(_authTokenKey);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the map to a JSON string before storage.
    final encodedData = jsonEncode(userData);
    await prefs.setString(_userDataKey, encodedData);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    // If no data has been stored, return null immediately.
    if (userDataString == null) return null;

    try {
      // Attempt to parse the JSON string back into a Map.
      // The cast is safe because we only ever store Map<String, dynamic>.
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      // If decoding fails (e.g., corrupted data), return null.
      // In a production app you might want to log this error.
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove both keys independently. If a key doesn't exist, the operation
    // still succeeds silently.
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userDataKey);
  }
}
