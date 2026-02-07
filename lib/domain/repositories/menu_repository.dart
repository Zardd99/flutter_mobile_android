import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/category.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

abstract class MenuRepository {
  Future<Result<List<MenuItem>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  });

  Future<Result<MenuItem>> getMenuItemById(String id, String? token);
  Future<Result<MenuItem>> createMenuItem(
    Map<String, dynamic> data,
    String token,
  );
  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
    String token,
  );
  Future<Result<void>> deleteMenuItem(String id, String token);

  Future<Result<List<Category>>> getAllCategories({
    String? name,
    bool? isActive,
    String? token,
  });
}
