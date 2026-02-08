import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';
import 'package:restaurant_mobile_app/domain/use_cases/create_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/delete_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/update_menu_item_use_case.dart';

class MenuManager {
  final MenuRepository _menuRepository;
  late final CreateMenuItemUseCase _createUseCase;
  late final UpdateMenuItemUseCase _updateUseCase;
  late final DeleteMenuItemUseCase _deleteUseCase;

  MenuManager(this._menuRepository) {
    _createUseCase = CreateMenuItemUseCase(_menuRepository);
    _updateUseCase = UpdateMenuItemUseCase(_menuRepository);
    _deleteUseCase = DeleteMenuItemUseCase(_menuRepository);
  }

  Future<Result<List<MenuItem>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
  }) async {
    return await _menuRepository.getAllMenuItems(
      category: category,
      dietary: dietary,
      search: search,
      available: available,
      chefSpecial: chefSpecial,
      token: null,
    );
  }

  Future<Result<MenuItem>> getMenuItemById(String id) async {
    return await _menuRepository.getMenuItemById(id, null);
  }

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

  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return await _updateUseCase.execute(id: id, updates: updates);
  }

  Future<Result<void>> deleteMenuItem(String id) async {
    return await _deleteUseCase.execute(id: id);
  }

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

  double calculateProfitMargin(double price, double cost) {
    if (cost <= 0) return 0.0;
    return ((price - cost) / price) * 100;
  }

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
