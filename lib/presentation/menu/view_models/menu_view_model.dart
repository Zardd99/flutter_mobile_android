/// 📁 menu_view_model.dart
///
/// Provides the ViewModel for the menu feature using the MVVM pattern.
/// It manages the state of menu items, loading status, error messages,
/// and filter criteria. It communicates with [MenuManager] to perform
/// all CRUD operations and notifies listeners of any state changes.
///
/// This class extends [ChangeNotifier] and is intended to be used with
/// Provider or similar state management solutions.

import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/presentation/menu/managers/menu_manager.dart';

/// A ChangeNotifier that serves as the ViewModel for the menu screen.
///
/// Holds the complete list of menu items, loading/error states, and the
/// currently active filters. Exposes methods to load, refresh, create,
/// update, delete, and filter menu items. All asynchronous operations
/// update the internal state and trigger a [notifyListeners] call.
class MenuViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Private Fields
  // ---------------------------------------------------------------------------

  /// The business logic layer responsible for menu item operations.
  final MenuManager _menuManager;

  /// The complete list of menu items retrieved from the data source.
  List<MenuItem> _menuItems = [];

  /// Indicates whether an asynchronous operation is currently in progress.
  bool _isLoading = false;

  /// The last error message that occurred during an operation, or `null` if none.
  String? _error;

  /// The currently selected category filter (category ID), or `null` if no filter.
  String? _categoryFilter;

  /// The current search query used to filter items by name/description, or `null`.
  String? _searchQuery;

  /// Whether to filter and show only available menu items.
  bool _availableOnly = false;

  /// Whether to filter and show only chef special items.
  bool _chefSpecialOnly = false;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a new [MenuViewModel] with the required [MenuManager] dependency.
  MenuViewModel(this._menuManager);

  // ---------------------------------------------------------------------------
  // Public Getters (State Exposure)
  // ---------------------------------------------------------------------------

  /// Returns the current unfiltered list of all menu items.
  List<MenuItem> get menuItems => _menuItems;

  /// Returns `true` if an asynchronous operation (load, create, update, delete)
  /// is currently being performed.
  bool get isLoading => _isLoading;

  /// Returns the last error message, or `null` if the last operation succeeded.
  String? get error => _error;

  /// Returns the currently applied category filter ID, or `null` if none.
  String? get categoryFilter => _categoryFilter;

  /// Returns the currently applied search query, or `null` if none.
  String? get searchQuery => _searchQuery;

  /// Returns `true` if the "available only" filter is active.
  bool get availableOnly => _availableOnly;

  /// Returns `true` if the "chef special only" filter is active.
  bool get chefSpecialOnly => _chefSpecialOnly;

  /// Returns the total number of menu items currently loaded.
  int get totalItems => _menuItems.length;

  /// Returns the count of menu items that are marked as available.
  int get availableItems =>
      _menuItems.where((item) => item.availability).length;

  /// Returns the count of menu items that are marked as chef specials.
  int get chefSpecials => _menuItems.where((item) => item.chefSpecial).length;

  // ---------------------------------------------------------------------------
  // Public Methods – Loading & Refreshing
  // ---------------------------------------------------------------------------

  /// Loads all menu items from the [MenuManager].
  ///
  /// Sets [_isLoading] to `true` during the operation, clears any previous error,
  /// and updates [_menuItems] with the result. On failure, [_error] is set and
  /// [_menuItems] is cleared. Always calls [notifyListeners] twice (before and after).
  Future<void> loadMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _menuManager.getAllMenuItems();

    result.fold(
      onSuccess: (items) {
        _menuItems = items;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
        _menuItems = [];
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Convenience method that simply calls [loadMenuItems].
  ///
  /// Useful for pull-to-refresh scenarios where the same load operation
  /// is required without additional logic.
  Future<void> refreshMenuItems() async {
    await loadMenuItems();
  }

  // ---------------------------------------------------------------------------
  // Public Methods – Single Item Retrieval
  // ---------------------------------------------------------------------------

  /// Fetches a single menu item by its unique identifier.
  ///
  /// Sets [_isLoading] to `true` during the operation and notifies listeners.
  /// Returns a [Result] containing the [MenuItem] on success, or a failure
  /// with an error message.
  Future<Result<MenuItem>> getMenuItemById(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.getMenuItemById(id);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // ---------------------------------------------------------------------------
  // Public Methods – CRUD Operations
  // ---------------------------------------------------------------------------

  /// Creates a new menu item with the provided details.
  ///
  /// Parameters:
  /// - [name], [description], [price], [categoryId], [dietaryTags], [preparationTime]
  /// - [chefSpecial] (default `false`)
  /// - [availability] (default `true`)
  ///
  /// Sets [_isLoading] to `true` during the operation. If creation succeeds,
  /// the new item is added to [_menuItems] and listeners are notified.
  /// Returns a [Result] containing the created [MenuItem] or a failure.
  Future<Result<MenuItem>> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> dietaryTags,
    required int preparationTime,
    bool chefSpecial = false,
    bool availability = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.createMenuItem(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      dietaryTags: dietaryTags,
      preparationTime: preparationTime,
      chefSpecial: chefSpecial,
      availability: availability,
    );

    _isLoading = false;

    if (result is Success<MenuItem>) {
      _menuItems.add(result.value);
      notifyListeners();
    }

    return result;
  }

  /// Updates an existing menu item with the provided [updates] map.
  ///
  /// The [updates] map can contain any fields of [MenuItem] that should be changed.
  /// Sets [_isLoading] to `true` during the operation. On success, the local
  /// [_menuItems] list is updated with the modified item and listeners are notified.
  /// Returns a [Result] containing the updated [MenuItem] or a failure.
  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.updateMenuItem(id, updates);

    _isLoading = false;

    if (result is Success<MenuItem>) {
      final index = _menuItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _menuItems[index] = result.value;
      }
      notifyListeners();
    }

    return result;
  }

  /// Deletes the menu item with the specified [id].
  ///
  /// Sets [_isLoading] to `true` during the operation. On success, the item
  /// is removed from [_menuItems] and listeners are notified.
  /// Returns a [Result<void>] indicating success or failure.
  Future<Result<void>> deleteMenuItem(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.deleteMenuItem(id);

    _isLoading = false;

    if (result is Success<void>) {
      _menuItems.removeWhere((item) => item.id == id);
      notifyListeners();
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Public Methods – Specific Operations
  // ---------------------------------------------------------------------------

  /// Toggles the availability status of the given [MenuItem].
  ///
  /// Creates an updates map with `{'availability': !item.availability}` and
  /// delegates to [updateMenuItem]. On success, the local list is updated and
  /// listeners are notified. On failure, [_error] is set.
  Future<void> toggleMenuItemAvailability(MenuItem item) async {
    final updates = {'availability': !item.availability};

    final result = await _menuManager.updateMenuItem(item.id, updates);

    result.fold(
      onSuccess: (updatedItem) {
        final index = _menuItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _menuItems[index] = updatedItem;
        }
        _error = null;
        notifyListeners();
      },
      onFailure: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Public Methods – Filter Management
  // ---------------------------------------------------------------------------

  /// Clears all active filters and reloads the full menu.
  ///
  /// Resets [_categoryFilter], [_searchQuery], [_availableOnly], and
  /// [_chefSpecialOnly] to their default (no filter) values, then calls
  /// [loadMenuItems] to refresh the list.
  void clearFilters() {
    _categoryFilter = null;
    _searchQuery = null;
    _availableOnly = false;
    _chefSpecialOnly = false;
    loadMenuItems();
  }
}
