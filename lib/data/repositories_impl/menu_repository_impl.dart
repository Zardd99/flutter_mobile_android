import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/category.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final RemoteDataSource _remoteDataSource;

  MenuRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<MenuItem>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    final result = await _remoteDataSource.getAllMenuItems(
      category: category,
      dietary: dietary,
      search: search,
      available: available,
      chefSpecial: chefSpecial,
      token: token,
    );

    return result.map((value) {
      final List<dynamic> data = value;
      return data.map((json) => MenuItem.fromJson(json)).toList();
    });
  }

  @override
  Future<Result<MenuItem>> getMenuItemById(String id, String? token) async {
    final result = await _remoteDataSource.getMenuItemById(id, token);
    return result.map((value) => MenuItem.fromJson(value));
  }

  @override
  Future<Result<MenuItem>> createMenuItem(
    Map<String, dynamic> data,
    String token,
  ) async {
    final result = await _remoteDataSource.createMenuItem(data, token);
    return result.map((value) => MenuItem.fromJson(value));
  }

  @override
  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final result = await _remoteDataSource.updateMenuItem(id, data, token);
    return result.map((value) => MenuItem.fromJson(value));
  }

  @override
  Future<Result<void>> deleteMenuItem(String id, String token) async {
    final result = await _remoteDataSource.deleteMenuItem(id, token);
    return result.map((_) {});
  }

  @override
  Future<Result<List<Category>>> getAllCategories({
    String? name,
    bool? isActive,
    String? token,
  }) async {
    final result = await _remoteDataSource.getAllCategories(
      name: name,
      isActive: isActive,
      token: token,
    );

    return result.map((value) {
      final List<dynamic> data = value;
      return data.map((json) => Category.fromJson(json)).toList();
    });
  }
}
