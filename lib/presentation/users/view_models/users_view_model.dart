// 📁 users_view_model.dart
///
/// This file defines the presentation logic for the user management screen.
/// It contains:
/// - [UserListItem]: an immutable UI representation of a user.
/// - [UsersViewModel]: a [ChangeNotifier] that handles loading, updating,
///   and deleting users, and manages the corresponding UI state.
///
/// The ViewModel communicates with [UserManager] and requires a valid
/// authentication token. It includes safeguards against state updates after
/// disposal.

import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/user.dart';
import 'package:restaurant_mobile_app/presentation/users/managers/user_manager.dart';

// -----------------------------------------------------------------------------
// UserListItem (UI Model)
// -----------------------------------------------------------------------------

/// Immutable representation of a user for display in the UI.
///
/// Transforms a domain [User] entity into a lightweight object that contains
/// only the data needed for the user list tile, including pre‑computed icons
/// and colors based on the user's role.
@immutable
class UserListItem {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// Unique identifier of the user.
  final String id;

  /// Full name of the user.
  final String name;

  /// Email address of the user.
  final String email;

  /// Role assigned to the user (e.g., 'admin', 'manager', 'waiter').
  final String role;

  /// Whether the user account is currently active.
  final bool isActive;

  /// Material icon representing the user's role.
  final IconData roleIcon;

  /// Color associated with the user's role (used for the icon).
  final Color roleColor;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a [UserListItem] with all required fields.
  const UserListItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.roleIcon,
    required this.roleColor,
  });

  // ---------------------------------------------------------------------------
  // Factory Constructor
  // ---------------------------------------------------------------------------

  /// Creates a [UserListItem] from a domain [User] entity.
  ///
  /// Determines the appropriate icon and color based on the user's role.
  factory UserListItem.fromUser(User user) {
    IconData roleIcon;
    Color roleColor;

    switch (user.role) {
      case 'admin':
        roleIcon = Icons.security;
        roleColor = Colors.red;
        break;
      case 'manager':
        roleIcon = Icons.manage_accounts;
        roleColor = Colors.blue;
        break;
      case 'chef':
        roleIcon = Icons.restaurant;
        roleColor = Colors.green;
        break;
      case 'waiter':
        roleIcon = Icons.delivery_dining;
        roleColor = Colors.orange;
        break;
      case 'cashier':
        roleIcon = Icons.point_of_sale;
        roleColor = Colors.purple;
        break;
      default:
        roleIcon = Icons.person;
        roleColor = Colors.grey;
    }

    return UserListItem(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      roleIcon: roleIcon,
      roleColor: roleColor,
    );
  }
}

// -----------------------------------------------------------------------------
// UsersViewModel (ChangeNotifier)
// -----------------------------------------------------------------------------

/// ViewModel for the user management screen.
///
/// Responsible for:
/// - Fetching the list of all users from the API.
/// - Deleting a user (with self‑deletion prevention).
/// - Toggling a user's active status.
/// - Holding loading and error states.
/// - Notifying the UI of any state changes.
///
/// This ViewModel uses a disposal guard (`_disposed`) to prevent
/// [notifyListeners] calls after the object has been disposed.
class UsersViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Private Fields
  // ---------------------------------------------------------------------------

  /// The business logic layer for user operations.
  final UserManager _userManager;

  /// Authentication token required for all API requests.
  final String _authToken;

  /// Indicates whether this ViewModel has been disposed.
  ///
  /// Used to prevent any state updates or listener notifications after disposal.
  bool _disposed = false;

  /// The current list of users, transformed into UI‑ready [UserListItem]s.
  List<UserListItem> _users = [];

  /// Whether an asynchronous operation (load, delete, update) is in progress.
  bool _isLoading = false;

  /// The last error message that occurred, or `null` if no error.
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // Public Getters (State Exposure)
  // ---------------------------------------------------------------------------

  /// Returns the list of users to be displayed.
  List<UserListItem> get users => _users;

  /// Returns `true` if a network operation is currently being performed.
  bool get isLoading => _isLoading;

  /// Returns the current error message, or `null` if none.
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a [UsersViewModel] with the required dependencies.
  UsersViewModel({required UserManager userManager, required String authToken})
    : _userManager = userManager,
      _authToken = authToken;

  // ---------------------------------------------------------------------------
  // Lifecycle Methods
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Public Methods – Data Loading
  // ---------------------------------------------------------------------------

  /// Fetches the complete list of users from the backend.
  ///
  /// Sets [_isLoading] to `true` during the request, clears any previous error,
  /// and updates [_users] with the transformed result. On failure, [_users]
  /// is cleared and [_errorMessage] is set.
  ///
  /// This method is safe to call even after disposal; it will return early.
  Future<void> loadUsers() async {
    // Guard: do nothing if already disposed.
    if (_disposed) return;

    _setLoading(true);
    _errorMessage = null;

    final result = await _userManager.getAllUsers(_authToken);

    // Guard: check disposal after the async operation.
    if (_disposed) return;

    result.fold(
      onSuccess: (users) {
        _users = users.map(UserListItem.fromUser).toList();
        _errorMessage = null;
      },
      onFailure: (failure) {
        _users = [];
        _errorMessage = failure.message;
      },
    );

    _setLoading(false);
  }

  // ---------------------------------------------------------------------------
  // Public Methods – User Operations
  // ---------------------------------------------------------------------------

  /// Deletes a user by their unique identifier.
  ///
  /// If [currentUserId] is provided and matches the [userId], the operation
  /// is rejected with an error message (self‑deletion is not allowed).
  ///
  /// Returns `true` if deletion succeeded, `false` otherwise.
  /// On success, the user is removed from the local [_users] list.
  Future<bool> deleteUser(String userId, {String? currentUserId}) async {
    // Guard: already disposed.
    if (_disposed) return false;

    // Business rule: prevent users from deleting themselves.
    if (currentUserId != null && currentUserId == userId) {
      _errorMessage = 'You cannot delete your own account';
      _safeNotify();
      return false;
    }

    final result = await _userManager.deleteUser(userId, _authToken);

    // Guard: disposed while waiting for network.
    if (_disposed) return false;

    return result.fold(
      onSuccess: (_) {
        // Guard again before mutating state.
        if (_disposed) return false;

        _users.removeWhere((user) => user.id == userId);
        _safeNotify();
        return true;
      },
      onFailure: (failure) {
        if (_disposed) return false;

        _errorMessage = failure.message;
        _safeNotify();
        return false;
      },
    );
  }

  /// Updates the active status of a user.
  ///
  /// Sends a partial update to the backend with `{'isActive': isActive}`.
  /// On success, the local [_users] list is updated with the fresh [User]
  /// object returned by the API.
  ///
  /// Returns `true` if the update succeeded, `false` otherwise.
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    if (_disposed) return false;

    final result = await _userManager.updateUser(
      userId: userId,
      data: {'isActive': isActive},
      token: _authToken,
    );

    if (_disposed) return false;

    return result.fold(
      onSuccess: (updatedUser) {
        if (_disposed) return false;

        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = UserListItem.fromUser(updatedUser);
        }
        _safeNotify();
        return true;
      },
      onFailure: (failure) {
        if (_disposed) return false;

        _errorMessage = failure.message;
        _safeNotify();
        return false;
      },
    );
  }

  /// Clears the current error message.
  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Updates the loading state and notifies listeners (if not disposed).
  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    _safeNotify();
  }

  /// Safely calls [notifyListeners] only if the ViewModel is not disposed.
  ///
  /// Prevents "notifyListeners called after dispose" errors.
  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
