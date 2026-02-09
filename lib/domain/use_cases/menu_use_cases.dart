// Standardized Result wrapper for success/failure handling
import 'package:restaurant_mobile_app/core/errors/result.dart';

// Domain entity representing a menu item
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

// Repository contract abstracting all menu-related data operations
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

// Re-export individual use cases to provide a clean public API
// for menu-related domain actions
export 'create_menu_item_use_case.dart';
export 'update_menu_item_use_case.dart';
export 'delete_menu_item_use_case.dart';

/// Use case responsible for retrieving all menu items.
///
/// Responsibilities:
/// - Acts as an application-layer query handler
/// - Accepts optional filters without enforcing UI concerns
/// - Delegates data access entirely to the repository
class GetAllMenuItemsUseCase {
  final MenuRepository _menuRepository;

  // Dependency injection ensures loose coupling and testability
  GetAllMenuItemsUseCase(this._menuRepository);

  /// Executes menu retrieval with optional filtering.
  ///
  /// Parameters:
  /// - Filters are nullable to allow flexible querying
  /// - Token is passed explicitly to avoid hidden global state
  ///
  /// Returns:
  /// - [Result<List<MenuItem>>] containing menu items or failure
  Future<Result<List<MenuItem>>> execute({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    // Delegate filtering and retrieval logic to repository
    return await _menuRepository.getAllMenuItems(
      category: category,
      dietary: dietary,
      search: search,
      available: available,
      chefSpecial: chefSpecial,
      token: token,
    );
  }
}

/// Use case responsible for creating a new menu item.
///
/// Note:
/// - Assumes data is already validated upstream
/// - Keeps use case thin and orchestration-focused
class CreateMenuItemUseCase {
  final MenuRepository _menuRepository;

  // Repository injected for inversion of control
  CreateMenuItemUseCase(this._menuRepository);

  /// Executes menu item creation.
  ///
  /// Parameters:
  /// - [data]: Serialized menu item payload
  /// - [token]: Authorization token required by backend
  ///
  /// Returns:
  /// - [Result<MenuItem>] containing created entity or failure
  Future<Result<MenuItem>> execute(
    Map<String, dynamic> data,
    String token,
  ) async {
    // Forward creation request to repository
    return await _menuRepository.createMenuItem(data, token);
  }
}

/// Use case responsible for updating an existing menu item.
///
/// Responsibilities:
/// - Acts as an application boundary for update operations
/// - Avoids leaking repository logic into UI layer
class UpdateMenuItemUseCase {
  final MenuRepository _menuRepository;

  UpdateMenuItemUseCase(this._menuRepository);

  /// Executes menu item update.
  ///
  /// Parameters:
  /// - [id]: Identifier of the menu item to update
  /// - [data]: Partial or full update payload
  /// - [token]: Authorization token
  ///
  /// Returns:
  /// - [Result<MenuItem>] containing updated entity or failure
  Future<Result<MenuItem>> execute(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    // Delegate update operation to repository
    return await _menuRepository.updateMenuItem(id, data, token);
  }
}

/// Use case responsible for deleting a menu item.
///
/// Responsibilities:
/// - Encapsulates delete intent in a dedicated use case
/// - Keeps UI free from repository-level concerns
class DeleteMenuItemUseCase {
  final MenuRepository _menuRepository;

  DeleteMenuItemUseCase(this._menuRepository);

  /// Executes menu item deletion.
  ///
  /// Parameters:
  /// - [id]: Identifier of the menu item to delete
  /// - [token]: Authorization token
  ///
  /// Returns:
  /// - [Result<void>] indicating success or failure
  Future<Result<void>> execute(String id, String token) async {
    // Forward deletion request to repository
    return await _menuRepository.deleteMenuItem(id, token);
  }
}
