import 'package:flutter/foundation.dart';
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

  Future<void> applyFilters({
    String? category,
    String? search,
    bool? available,
    bool? chefSpecial,
  }) async {
    _categoryFilter = category;
    _searchQuery = search;
    _availableOnly = available ?? false;
    _chefSpecialOnly = chefSpecial ?? false;

    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.filterMenuItems(
      category: category,
      searchQuery: search,
      availableOnly: available,
      chefSpecialOnly: chefSpecial,
    );

    result.fold(
      onSuccess: (items) {
        _menuItems = items;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshMenuItems() async {
    await loadMenuItems();
  }

  Future<void> deleteMenuItem(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.deleteMenuItem(id);

    result.fold(
      onSuccess: (_) {
        _menuItems.removeWhere((item) => item.id == id);
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

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

  void clearFilters() {
    _categoryFilter = null;
    _searchQuery = null;
    _availableOnly = false;
    _chefSpecialOnly = false;
    loadMenuItems();
  }

  List<MenuItem> get filteredMenuItems {
    return _menuItems;
  }

  int get totalItems => _menuItems.length;

  int get availableItems =>
      _menuItems.where((item) => item.availability).length;

  int get chefSpecials => _menuItems.where((item) => item.chefSpecial).length;
}
