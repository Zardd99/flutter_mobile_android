// Failure types used to represent validation and domain-level errors
import 'package:restaurant_mobile_app/core/errors/failure.dart';

// Standard Result wrapper to unify success and error handling
import 'package:restaurant_mobile_app/core/errors/result.dart';

// Domain entity representing a menu item
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

// Repository contract abstracting menu-related persistence operations
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

// Validator responsible for enforcing menu item update business rules
import 'package:restaurant_mobile_app/domain/validators/menu_item_validator.dart';

/// Use case responsible for updating an existing menu item.
///
/// Responsibilities:
/// - Enforce domain validation before data-layer interaction
/// - Prevent invalid or empty update operations
/// - Coordinate validation and repository update flow
class UpdateMenuItemUseCase {
  final MenuRepository _repository;

  // Repository injection supports clean architecture and testability
  UpdateMenuItemUseCase(this._repository);

  /// Executes the menu item update operation.
  ///
  /// Parameters:
  /// - [id]: Unique identifier of the menu item to update
  /// - [updates]: Partial update payload provided by the caller
  /// - [authToken]: Optional authentication token for authorized requests
  ///
  /// Returns:
  /// - [Result<MenuItem>] containing the updated entity or a failure
  Future<Result<MenuItem>> execute({
    required String id,
    required Map<String, dynamic> updates,
    String? authToken,
  }) async {
    // Guard clause to prevent empty update requests
    // Avoids unnecessary validation and repository calls
    if (updates.isEmpty) {
      return ResultFailure(ValidationFailure('No updates provided'));
    }

    // Validate update data against domain rules
    // Only provided fields are validated; others are ignored
    final validation = MenuItemValidator.validateUpdateData(
      name: updates['name'],
      description: updates['description'],
      price: updates['price'],
      categoryId: updates['category'],
      dietaryTags: updates['dietaryTags'],
      preparationTime: updates['preparationTime'],
      chefSpecial: updates['chefSpecial'],
      availability: updates['availability'],
    );

    // If validation succeeds, map validated data into repository update call
    // Validation failures short-circuit automatically via Result
    return await validation.asyncMap<MenuItem>((validatedData) async {
      // Delegate persistence logic to repository with explicit auth token
      return await _repository.updateMenuItem(
        id,
        validatedData,
        authToken ?? '',
      );
    });
  }
}
