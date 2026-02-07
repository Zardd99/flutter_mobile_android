import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

class GetAllMenuItemsUseCase {
  final MenuRepository _menuRepository;

  GetAllMenuItemsUseCase(this._menuRepository);

  Future<Result<List<MenuItem>>> execute({
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
}

class CreateMenuItemUseCase {
  final MenuRepository _menuRepository;

  CreateMenuItemUseCase(this._menuRepository);

  Future<Result<MenuItem>> execute(
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _menuRepository.createMenuItem(data, token);
  }
}

class UpdateMenuItemUseCase {
  final MenuRepository _menuRepository;

  UpdateMenuItemUseCase(this._menuRepository);

  Future<Result<MenuItem>> execute(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return await _menuRepository.updateMenuItem(id, data, token);
  }
}

class DeleteMenuItemUseCase {
  final MenuRepository _menuRepository;

  DeleteMenuItemUseCase(this._menuRepository);

  Future<Result<void>> execute(String id, String token) async {
    return await _menuRepository.deleteMenuItem(id, token);
  }
}
