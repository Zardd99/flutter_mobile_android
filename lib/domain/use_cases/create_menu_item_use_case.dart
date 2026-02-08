import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';
import 'package:restaurant_mobile_app/domain/validators/menu_item_validator.dart';

class CreateMenuItemUseCase {
  final MenuRepository _repository;

  CreateMenuItemUseCase(this._repository);

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

    return await validation.asyncMap<MenuItem>((data) async {
      return await _repository.createMenuItem(data.toJson(), authToken ?? '');
    });
  }
}
