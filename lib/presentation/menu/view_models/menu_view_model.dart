import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/presentation/menu/managers/menu_manager.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuManager _menuManager;

  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  String? _categoryFilter;
  String? _searchQuery;
  bool _availableOnly = false;
  bool _chefSpecialOnly = false;

  MenuViewModel(this._menuManager);

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get categoryFilter => _categoryFilter;
  String? get searchQuery => _searchQuery;
  bool get availableOnly => _availableOnly;
  bool get chefSpecialOnly => _chefSpecialOnly;

  // Add missing method: loadMenuItems
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

  // Add missing method: refreshMenuItems
  Future<void> refreshMenuItems() async {
    await loadMenuItems();
  }

  // Add missing method: toggleMenuItemAvailability
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

  Future<Result<MenuItem>> getMenuItemById(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.getMenuItemById(id);

    _isLoading = false;
    notifyListeners();

    return result;
  }

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

  void clearFilters() {
    _categoryFilter = null;
    _searchQuery = null;
    _availableOnly = false;
    _chefSpecialOnly = false;
    loadMenuItems();
  }

  int get totalItems => _menuItems.length;
  int get availableItems =>
      _menuItems.where((item) => item.availability).length;
  int get chefSpecials => _menuItems.where((item) => item.chefSpecial).length;
}
