import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';
import 'package:restaurant_mobile_app/domain/validators/menu_item_validator.dart';

class UpdateMenuItemUseCase {
  final MenuRepository _repository;

  UpdateMenuItemUseCase(this._repository);

  Future<Result<MenuItem>> execute({
    required String id,
    required Map<String, dynamic> updates,
    String? authToken,
  }) async {
    if (updates.isEmpty) {
      return ResultFailure(ValidationFailure('No updates provided'));
    }

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

    return await validation.asyncMap<MenuItem>((validatedData) async {
      return await _repository.updateMenuItem(
        id,
        validatedData,
        authToken ?? '',
      );
    });
  }
}
