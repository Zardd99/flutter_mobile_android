import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/category.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

/// Concrete implementation of the [MenuRepository] contract.
///
/// This class acts as a bridge between the domain layer and the data layer.
/// It receives requests from the domain (or presentation) layer, delegates
/// the actual data fetching/operations to the [RemoteDataSource], and maps
/// the raw JSON responses into domain entities ([MenuItem], [Category]).
///
/// All methods return a [Result] type, encapsulating either a successful
/// value or a failure with an error. This pattern ensures explicit error
/// handling without exceptions.
class MenuRepositoryImpl implements MenuRepository {
  /// The remote data source responsible for making API calls.
  final RemoteDataSource _remoteDataSource;

  /// Creates a new [MenuRepositoryImpl] with the given remote data source.
  MenuRepositoryImpl(this._remoteDataSource);

  // ---------------------------------------------------------------------------
  // Menu Item Operations
  // ---------------------------------------------------------------------------

  @override
  Future<Result<List<MenuItem>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    // Delegate the request to the remote data source.
    final result = await _remoteDataSource.getAllMenuItems(
      category: category,
      dietary: dietary,
      search: search,
      available: available,
      chefSpecial: chefSpecial,
      token: token,
    );

    // Transform the successful raw JSON list into a list of MenuItem entities.
    return result.map((value) {
      final List<dynamic> data = value;
      return data.map((json) => MenuItem.fromJson(json)).toList();
    });
  }

  @override
  Future<Result<MenuItem>> getMenuItemById(String id, String? token) async {
    final result = await _remoteDataSource.getMenuItemById(id, token);
    // Single JSON object -> single MenuItem entity.
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
    // Void result: discard the value and return a successful Result<void>.
    return result.map((_) {});
  }

  // ---------------------------------------------------------------------------
  // Category Operations
  // ---------------------------------------------------------------------------

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

    // Transform the raw JSON list into a list of Category entities.
    return result.map((value) {
      final List<dynamic> data = value;
      return data.map((json) => Category.fromJson(json)).toList();
    });
  }
}
