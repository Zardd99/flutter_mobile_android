import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/domain/entities/cart_item.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/presentation/menu/managers/menu_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';

/// ViewModel for the Waiter Order Creation screen.
///
/// This [ChangeNotifier] manages the complete state of the order creation flow
/// for waiters/waitstaff. It handles:
/// - Fetching and filtering the menu.
/// - Managing the shopping cart (add/remove, quantity, special instructions).
/// - Capturing order metadata (table number, customer name, notes).
/// - Submitting the completed order via [OrderManager].
///
/// The state is exposed via getters and notifies listeners on every change.
class WaiterOrderViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final MenuManager _menuManager;
  final OrderManager _orderManager;
  final String _authToken;

  // ---------------------------------------------------------------------------
  // Menu State
  // ---------------------------------------------------------------------------

  /// The complete, unfiltered list of menu items fetched from the backend.
  List<MenuItem> _allMenuItems = [];

  /// List of unique category names extracted from [_allMenuItems].
  List<String> _categories = [];

  /// Indicates whether a menu fetch operation is in progress.
  bool _isLoadingMenu = false;

  /// Error message from the last menu fetch operation, if any.
  String? _menuError;

  // ---------------------------------------------------------------------------
  // Cart State
  // ---------------------------------------------------------------------------

  /// Current items in the shopping cart.
  List<CartItem> _cart = [];

  /// Table number for this order (dine‑in only).
  int? _tableNumber;

  /// Optional customer name for the order.
  String? _customerName;

  /// Optional global notes for the order.
  String? _orderNotes;

  // ---------------------------------------------------------------------------
  // Filter & Sort State
  // ---------------------------------------------------------------------------

  String _searchTerm = '';
  List<String> _selectedCategories = const ['all'];
  String _availabilityFilter = 'all';
  String _chefSpecialFilter = 'all';
  String _priceSort = 'none';
  String _activeQuickFilter = 'all';

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a new [WaiterOrderViewModel] with the required dependencies.
  ///
  /// Immediately triggers [loadMenuItems] to populate the menu.
  WaiterOrderViewModel({
    required MenuManager menuManager,
    required OrderManager orderManager,
    required String authToken,
  }) : _menuManager = menuManager,
       _orderManager = orderManager,
       _authToken = authToken {
    loadMenuItems();
  }

  // ---------------------------------------------------------------------------
  // Menu – Public Getters
  // ---------------------------------------------------------------------------

  /// The filtered and sorted list of menu items based on all active filters.
  List<MenuItem> get filteredMenuItems => _applyFilters();

  /// All available category names (extracted from the menu).
  List<String> get categories => _categories;

  /// `true` while the menu is being fetched for the first time.
  bool get isLoadingMenu => _isLoadingMenu;

  /// Error message from the last menu fetch, or `null` if successful.
  String? get menuError => _menuError;

  // ---------------------------------------------------------------------------
  // Cart – Public Getters & Computed Properties
  // ---------------------------------------------------------------------------

  /// The current shopping cart contents.
  List<CartItem> get cart => _cart;

  /// Sum of (price × quantity) for all items in the cart.
  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.total);

  /// Tax amount (currently fixed at 10% of subtotal).
  double get tax => subtotal * 0.1;

  /// Final total including tax.
  double get total => subtotal + tax;

  /// Table number for this order. `null` if not yet set.
  int? get tableNumber => _tableNumber;

  /// Sets the table number and notifies listeners.
  set tableNumber(int? value) {
    _tableNumber = value;
    notifyListeners();
  }

  /// Optional customer name.
  String? get customerName => _customerName;

  /// Sets the customer name and notifies listeners.
  set customerName(String? value) {
    _customerName = value;
    notifyListeners();
  }

  /// Optional order‑level notes.
  String? get orderNotes => _orderNotes;

  /// Sets the order notes and notifies listeners.
  set orderNotes(String? value) {
    _orderNotes = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filter & Sort – Public Getters / Setters
  // ---------------------------------------------------------------------------

  /// Current search term (matched against item name and description).
  String get searchTerm => _searchTerm;
  set searchTerm(String value) {
    _searchTerm = value;
    notifyListeners();
  }

  /// List of selected category names. Use `['all']` to disable category filtering.
  List<String> get selectedCategories => _selectedCategories;
  set selectedCategories(List<String> value) {
    _selectedCategories = value;
    notifyListeners();
  }

  /// Availability filter: `'all'`, `'available'`, or `'unavailable'`.
  String get availabilityFilter => _availabilityFilter;
  set availabilityFilter(String value) {
    _availabilityFilter = value;
    notifyListeners();
  }

  /// Chef special filter: `'all'`, `'special'`, or `'regular'`.
  String get chefSpecialFilter => _chefSpecialFilter;
  set chefSpecialFilter(String value) {
    _chefSpecialFilter = value;
    notifyListeners();
  }

  /// Price sort order: `'none'`, `'low'`, or `'high'`.
  String get priceSort => _priceSort;
  set priceSort(String value) {
    _priceSort = value;
    notifyListeners();
  }

  /// Currently active quick filter: `'all'`, `'popular'`, `'chef'`, `'veg'`, `'fast'`.
  String get activeQuickFilter => _activeQuickFilter;
  set activeQuickFilter(String value) {
    _activeQuickFilter = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Menu Operations
  // ---------------------------------------------------------------------------

  /// Fetches all menu items from the remote data source.
  ///
  /// Sets [_isLoadingMenu] to `true` while the request is in progress.
  /// On success, updates [_allMenuItems] and [_categories], clears any error.
  /// On failure, stores the error message in [_menuError].
  /// Notifies listeners on both start and completion.
  Future<void> loadMenuItems() async {
    _isLoadingMenu = true;
    _menuError = null;
    notifyListeners();

    final result = await _menuManager.getAllMenuItems(token: _authToken);
    result.fold(
      onSuccess: (items) {
        _allMenuItems = items;
        _extractCategories();
        _isLoadingMenu = false;
        notifyListeners();
      },
      onFailure: (failure) {
        _menuError = failure.message;
        _isLoadingMenu = false;
        notifyListeners();
      },
    );
  }

  /// Extracts unique, non‑empty category names from [_allMenuItems].
  /// Sorts the result alphabetically and stores it in [_categories].
  void _extractCategories() {
    final Set<String> cats = {};
    for (var item in _allMenuItems) {
      if (item.categoryName != null && item.categoryName!.isNotEmpty) {
        cats.add(item.categoryName!);
      }
    }
    _categories = cats.toList()..sort();
  }

  // ---------------------------------------------------------------------------
  // Filtering Logic (Private)
  // ---------------------------------------------------------------------------

  /// Applies all active filters and sorting to the complete menu list.
  ///
  /// The order of operations is:
  /// 1. Quick filters
  /// 2. Text search
  /// 3. Category filter
  /// 4. Availability filter
  /// 5. Chef special filter
  /// 6. Price sorting
  List<MenuItem> _applyFilters() {
    var filtered = List<MenuItem>.from(_allMenuItems);

    // 1. Quick filters
    switch (_activeQuickFilter) {
      case 'popular':
        // Currently no popularity data; keep all items.
        filtered = filtered.where((item) => true).toList();
        break;
      case 'chef':
        filtered = filtered.where((item) => item.chefSpecial).toList();
        break;
      case 'veg':
        filtered = filtered
            .where(
              (item) =>
                  item.dietaryTags.contains('vegetarian') ||
                  item.dietaryTags.contains('vegan'),
            )
            .toList();
        break;
      case 'fast':
        filtered = filtered
            .where((item) => item.preparationTime <= 15)
            .toList();
        break;
    }

    // 2. Text search
    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(term) ||
                item.description.toLowerCase().contains(term),
          )
          .toList();
    }

    // 3. Category filter
    if (!_selectedCategories.contains('all') &&
        _selectedCategories.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.categoryName != null &&
            _selectedCategories.contains(item.categoryName);
      }).toList();
    }

    // 4. Availability filter
    if (_availabilityFilter == 'available') {
      filtered = filtered.where((item) => item.availability).toList();
    } else if (_availabilityFilter == 'unavailable') {
      filtered = filtered.where((item) => !item.availability).toList();
    }

    // 5. Chef special filter
    if (_chefSpecialFilter == 'special') {
      filtered = filtered.where((item) => item.chefSpecial).toList();
    } else if (_chefSpecialFilter == 'regular') {
      filtered = filtered.where((item) => !item.chefSpecial).toList();
    }

    // 6. Price sorting
    switch (_priceSort) {
      case 'low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        // Placeholder for future rating-based sorting.
        break;
    }

    return filtered;
  }

  // ---------------------------------------------------------------------------
  // Cart Actions
  // ---------------------------------------------------------------------------

  /// Adds one unit of the given [MenuItem] to the cart.
  ///
  /// If the item already exists in the cart, its quantity is increased by 1.
  /// Otherwise, a new [CartItem] with quantity 1 is created.
  void addToCart(MenuItem item) {
    final existingIndex = _cart.indexWhere((ci) => ci.menuItem.id == item.id);
    if (existingIndex != -1) {
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + 1,
      );
    } else {
      _cart.add(CartItem(menuItem: item));
    }
    notifyListeners();
  }

  /// Updates the quantity of a cart item.
  ///
  /// If [quantity] is 0 or negative, the item is removed from the cart.
  /// Otherwise, the item’s quantity is set to the given value.
  void updateQuantity(String menuItemId, int quantity) {
    final index = _cart.indexWhere((ci) => ci.menuItem.id == menuItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  /// Adds or updates special instructions for a cart item.
  void updateSpecialInstructions(String menuItemId, String instructions) {
    final index = _cart.indexWhere((ci) => ci.menuItem.id == menuItemId);
    if (index != -1) {
      _cart[index] = _cart[index].copyWith(specialInstructions: instructions);
      notifyListeners();
    }
  }

  /// Removes a cart item entirely.
  void removeFromCart(String menuItemId) {
    _cart.removeWhere((ci) => ci.menuItem.id == menuItemId);
    notifyListeners();
  }

  /// Empties the entire cart.
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Order Submission
  // ---------------------------------------------------------------------------

  /// Submits the current order to the backend.
  ///
  /// Throws an [Exception] if:
  /// - The cart is empty.
  /// - No table number is set or the table number is less than 1.
  ///
  /// On success, clears the cart and resets order metadata.
  /// On failure, re‑throws the error.
  Future<void> submitOrder() async {
    if (_cart.isEmpty) {
      throw Exception('Cart is empty');
    }
    if (_tableNumber == null || _tableNumber! < 1) {
      throw Exception('Please enter a valid table number');
    }

    final orderData = {
      'items': _cart.map((item) {
        return {
          'menuItem': item.menuItem.id,
          'quantity': item.quantity,
          'specialInstructions': item.specialInstructions ?? '',
          'price': item.menuItem.price,
        };
      }).toList(),
      'totalAmount': total,
      'tableNumber': _tableNumber,
      'orderType': 'dine-in',
      'status': 'confirmed',
    };

    final result = await _orderManager.createOrder(
      orderData: orderData,
      token: _authToken,
    );

    result.fold(
      onSuccess: (_) {
        clearCart();
        _tableNumber = null;
        _customerName = null;
        _orderNotes = null;
        notifyListeners();
      },
      onFailure: (failure) {
        throw Exception(failure.message);
      },
    );
  }
}
