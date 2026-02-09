// Standardized result wrapper used to represent success or failure
import 'package:restaurant_mobile_app/core/errors/result.dart';

// Domain entity representing a menu item
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

// Repository contract that abstracts data source operations
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

// Centralized validator responsible for enforcing menu item business rules
import 'package:restaurant_mobile_app/domain/validators/menu_item_validator.dart';

/// Use case responsible for creating a new menu item.
///
/// Responsibilities:
/// - Validate incoming data before any persistence occurs
/// - Coordinate between validation logic and repository layer
/// - Ensure clean separation between UI, domain, and data layers
class CreateMenuItemUseCase {
  final MenuRepository _repository;

  // Repository is injected to support dependency inversion and testability
  CreateMenuItemUseCase(this._repository);

  /// Executes the menu item creation flow.
  ///
  /// Parameters:
  /// - Uses named parameters for clarity and self-documentation
  /// - Optional flags provide sensible defaults for business behavior
  /// - [authToken] is passed explicitly to avoid hidden global state
  ///
  /// Returns:
  /// - [Result<MenuItem>] encapsulating either the created entity or a failure
  Future<Result<MenuItem>> execute({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> dietaryTags,
    required int preparationTime,
    bool chefSpecial = false,
    bool availability = true,
    String? authToken,
  }) async {
    // Perform synchronous domain validation before hitting data layer
    // This ensures invalid business data never reaches the repository
    final validation = MenuItemValidator.validateCreationData(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      dietaryTags: dietaryTags,
      preparationTime: preparationTime,
      chefSpecial: chefSpecial,
      availability: availability,
    );

    // If validation succeeds, asynchronously map the valid data
    // into a repository call; failures short-circuit automatically
    return await validation.asyncMap<MenuItem>((data) async {
      // Convert validated domain data into a serializable format
      // and delegate persistence to the repository
      return await _repository.createMenuItem(data.toJson(), authToken ?? '');
    });
  }
}
