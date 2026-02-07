import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

class MenuManager {
  final MenuRepository _menuRepository;

  MenuManager(this._menuRepository);

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
    );
  }

  Future<Result<MenuItem>> getMenuItemById(String id) async {
    return await _menuRepository.getMenuItemById(id, null);
  }

  Future<Result<MenuItem>> createMenuItem(
    String name,
    String description,
    double price,
    String categoryId,
    List<Map<String, dynamic>> ingredients,
    List<String> dietaryTags,
    int preparationTime,
    bool chefSpecial,
    bool availability,
  ) async {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'ingredientReferences': ingredients,
      'dietaryTags': dietaryTags,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      'availability': availability,
    };
    return await _menuRepository.createMenuItem(data, '');
  }

  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return await _menuRepository.updateMenuItem(id, updates, '');
  }

  Future<Result<void>> deleteMenuItem(String id) async {
    return await _menuRepository.deleteMenuItem(id, '');
  }

  Future<Result<List<MenuItem>>> filterMenuItems({
    required String? category,
    required String? searchQuery,
    required bool? availableOnly,
    required bool? chefSpecialOnly,
  }) async {
    final result = await _menuRepository.getAllMenuItems(
      category: category,
      search: searchQuery,
      available: availableOnly,
      chefSpecial: chefSpecialOnly,
    );

    return result.map((items) {
      return items.where((item) {
        bool matches = true;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          matches =
              matches &&
              (item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  item.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ));
        }
        if (availableOnly == true) {
          matches = matches && item.availability;
        }
        if (chefSpecialOnly == true) {
          matches = matches && item.chefSpecial;
        }
        return matches;
      }).toList();
    });
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
