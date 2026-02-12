// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/menu/managers/menu_manager.dart
// Description: Business logic controller for menu management.
//              Acts as a facade between the UI and the domain layer,
//              encapsulating use cases and providing simple methods
//              for menu item operations.
// *****************************************************************************

import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';
import 'package:restaurant_mobile_app/domain/use_cases/create_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/delete_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/update_menu_item_use_case.dart';

/// Manages all menu-related operations for the presentation layer.
///
/// This class is a ViewModel/Manager that:
///   - Provides a clean, UI‑friendly API for menu item operations.
///   - Wraps and orchestrates domain use cases.
///   - Handles simple business validation and utility calculations.
///   - Returns [Result] objects to communicate success/failure.
///
/// It does **not** hold any mutable state; all methods are asynchronous
/// and rely on the injected [MenuRepository] and use cases.
class MenuManager {
  // -------------------------------------------------------------------------
  // DEPENDENCIES
  // -------------------------------------------------------------------------

  /// The repository that provides access to menu data (local/remote).
  final MenuRepository _menuRepository;

  /// Use case for creating a new menu item.
  late final CreateMenuItemUseCase _createUseCase;

  /// Use case for updating an existing menu item.
  late final UpdateMenuItemUseCase _updateUseCase;

  /// Use case for deleting a menu item.
  late final DeleteMenuItemUseCase _deleteUseCase;

  // -------------------------------------------------------------------------
  // CONSTRUCTOR
  // -------------------------------------------------------------------------

  /// Creates a new [MenuManager] with the required repository.
  ///
  /// Use cases are instantiated immediately after the constructor body
  /// using late final initialization to ensure they are ready when needed.
  MenuManager(this._menuRepository) {
    _createUseCase = CreateMenuItemUseCase(_menuRepository);
    _updateUseCase = UpdateMenuItemUseCase(_menuRepository);
    _deleteUseCase = DeleteMenuItemUseCase(_menuRepository);
  }

  // -------------------------------------------------------------------------
  // MENU ITEM RETRIEVAL
  // -------------------------------------------------------------------------

  /// Fetches a list of menu items, optionally filtered by various criteria.
  ///
  /// Parameters:
  ///   [category]   – filter by category ID.
  ///   [dietary]    – filter by dietary tag (e.g., "vegan", "gluten‑free").
  ///   [search]     – full‑text search on name/description.
  ///   [available]  – if `true`, return only available items; if `false`, only unavailable.
  ///   [chefSpecial]– filter by chef special flag.
  ///   [token]      – optional authentication token (required for admin operations).
  ///
  /// Returns a [Result] containing a list of [MenuItem] on success,
  /// or a [Failure] on error.
  Future<Result<List<MenuItem>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    return await _menuRepository.getAllMenuItems(
      category: category,
      dietary: dietary,
      search: search,
      available: available,
      chefSpecial: chefSpecial,
      token: token,
    );
  }

  /// Retrieves a single menu item by its unique identifier.
  ///
  /// This method is intended for public (non‑admin) viewing;
  /// therefore no token is passed.
  ///
  /// Returns a [Result] containing the [MenuItem] if found,
  /// or a [Failure] (e.g., not found, network error).
  Future<Result<MenuItem>> getMenuItemById(String id) async {
    return await _menuRepository.getMenuItemById(id, null);
  }

  /// Filters menu items based on user‑selected criteria.
  ///
  /// This is a convenience wrapper around [getAllMenuItems] with a
  /// simplified parameter list, typically used by the customer‑facing UI.
  ///
  /// Parameters:
  ///   [category]       – filter by category ID.
  ///   [searchQuery]    – text search.
  ///   [availableOnly]  – show only available items.
  ///   [chefSpecialOnly]– show only chef specials.
  ///
  /// Always calls the repository without a token (public access).
  Future<Result<List<MenuItem>>> filterMenuItems({
    required String? category,
    required String? searchQuery,
    required bool? availableOnly,
    required bool? chefSpecialOnly,
  }) async {
    return await _menuRepository.getAllMenuItems(
      category: category,
      search: searchQuery,
      available: availableOnly,
      chefSpecial: chefSpecialOnly,
      token: null,
    );
  }

  // -------------------------------------------------------------------------
  // MENU ITEM MUTATIONS (ADMIN ONLY)
  // -------------------------------------------------------------------------

  /// Creates a new menu item.
  ///
  /// All parameters are required except [chefSpecial] and [availability],
  /// which default to `false` and `true` respectively.
  ///
  /// This method uses the [CreateMenuItemUseCase] which internally handles
  /// authentication and repository communication.
  ///
  /// Returns a [Result] containing the newly created [MenuItem].
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
    return await _createUseCase.execute(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      dietaryTags: dietaryTags,
      preparationTime: preparationTime,
      chefSpecial: chefSpecial,
      availability: availability,
    );
  }

  /// Updates an existing menu item.
  ///
  /// [id]      – the unique identifier of the item to update.
  /// [updates] – a map containing the fields to modify and their new values.
  ///
  /// Uses the [UpdateMenuItemUseCase] to perform the operation.
  ///
  /// Returns the updated [MenuItem] on success.
  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return await _updateUseCase.execute(id: id, updates: updates);
  }

  /// Deletes a menu item by its ID.
  ///
  /// Uses the [DeleteMenuItemUseCase]. Returns a void [Result]
  /// that indicates success or contains a [Failure].
  Future<Result<void>> deleteMenuItem(String id) async {
    return await _deleteUseCase.execute(id: id);
  }

  // -------------------------------------------------------------------------
  // UTILITY / BUSINESS HELPER METHODS
  // -------------------------------------------------------------------------

  /// Calculates the profit margin percentage for a menu item.
  ///
  /// Formula: `((price - cost) / price) * 100`.
  /// If [cost] is zero or negative, returns 0.0 to avoid division errors.
  ///
  /// This is a pure calculation and does not involve any repository call.
  double calculateProfitMargin(double price, double cost) {
    if (cost <= 0) return 0.0;
    return ((price - cost) / price) * 100;
  }

  /// Validates the basic data required to create or update a menu item.
  ///
  /// Checks that:
  ///   - name is not empty.
  ///   - description is not empty.
  ///   - price is positive (> 0).
  ///   - categoryId is not empty.
  ///   - preparationTime is positive (> 0).
  ///
  /// Returns `true` if all conditions are met, otherwise `false`.
  ///
  /// This method is intended for client‑side validation before
  /// submitting data to the server.
  bool validateMenuItemData({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required int preparationTime,
  }) {
    return name.isNotEmpty &&
        description.isNotEmpty &&
        price > 0 &&
        categoryId.isNotEmpty &&
        preparationTime > 0;
  }
}
