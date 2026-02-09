// Failure definitions used to represent domain and validation errors
import 'package:restaurant_mobile_app/core/errors/failure.dart';

// Result wrapper used to unify success and error handling
import 'package:restaurant_mobile_app/core/errors/result.dart';

// Repository contract abstracting menu-related data operations
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

/// Use case responsible for deleting an existing menu item.
///
/// Responsibilities:
/// - Enforce minimal domain validation before data-layer interaction
/// - Act as the single entry point for delete operations from the UI
/// - Delegate persistence logic to the repository layer
class DeleteMenuItemUseCase {
  final MenuRepository _repository;

  // Repository injection supports testability and clean architecture principles
  DeleteMenuItemUseCase(this._repository);

  /// Executes the delete menu item operation.
  ///
  /// Parameters:
  /// - [id]: Unique identifier of the menu item to be deleted
  /// - [authToken]: Optional authentication token for authorized requests
  ///
  /// Returns:
  /// - [Result<void>] indicating success or failure without payload
  Future<Result<void>> execute({required String id, String? authToken}) async {
    // Guard clause to prevent invalid delete requests
    // Avoids unnecessary repository or network calls
    if (id.isEmpty) {
      return ResultFailure(Failure.validation('Menu item ID is required'));
    }

    // Delegate deletion to repository, passing auth token explicitly
    return await _repository.deleteMenuItem(id, authToken ?? '');
  }
}
