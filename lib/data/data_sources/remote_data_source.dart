import 'package:restaurant_mobile_app/core/constants/api_constants.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/core/network/api_client.dart';

class RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSource({required this.apiClient});

  // Auth
  Future<Result<Map<String, dynamic>>> login(
    Map<String, dynamic> credentials,
  ) async {
    return apiClient.post(ApiConstants.authLogin, credentials);
  }

  Future<Result<Map<String, dynamic>>> register(
    Map<String, dynamic> data,
  ) async {
    return apiClient.post(ApiConstants.authRegister, data);
  }

  Future<Result<Map<String, dynamic>>> getCurrentUser(String token) async {
    return apiClient.get(ApiConstants.authMe, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put(ApiConstants.authUpdate, data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> changePassword(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put(
      ApiConstants.authChangePassword,
      data,
      authToken: token,
    );
  }

  // Menu
  // Replace the entire method or fix just the if statement
  Future<Result<List<dynamic>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) {
      queryParams['category'] = category;
    }
    if (dietary != null) {
      queryParams['dietary'] = dietary;
    }
    if (search != null) {
      queryParams['search'] = search;
    }
    if (available != null) {
      queryParams['available'] = available.toString();
    }
    if (chefSpecial != null) {
      queryParams['chefSpecial'] = chefSpecial.toString();
    }

    return apiClient.getList(
      ApiConstants.menu,
      queryParams: queryParams,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> getMenuItemById(
    String id,
    String? token,
  ) async {
    return apiClient.get('${ApiConstants.menu}/$id', authToken: token);
  }

  Future<Result<Map<String, dynamic>>> createMenuItem(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.post(ApiConstants.menu, data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put('${ApiConstants.menu}/$id', data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> deleteMenuItem(
    String id,
    String token,
  ) async {
    return apiClient.delete('${ApiConstants.menu}/$id', authToken: token);
  }

  // Categories
  Future<Result<List<dynamic>>> getAllCategories({
    String? name,
    bool? isActive,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (name != null) queryParams['name'] = name;
    if (isActive != null) queryParams['isActive'] = isActive.toString();

    return apiClient.getList(
      ApiConstants.categories,
      queryParams: queryParams,
      authToken: token,
    );
  }

  // Orders
  Future<Result<List<dynamic>>> getAllOrders({
    String? status,
    String? customer,
    String? orderType,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (customer != null) queryParams['customer'] = customer;
    if (orderType != null) queryParams['orderType'] = orderType;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (minAmount != null) {
      queryParams['minAmount'] = minAmount.toString();
    }
    if (maxAmount != null) {
      queryParams['maxAmount'] = maxAmount.toString();
    }

    return apiClient.getList(
      ApiConstants.orders,
      queryParams: queryParams,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> getOrderById(
    String id,
    String token,
  ) async {
    return apiClient.get('${ApiConstants.orders}/$id', authToken: token);
  }

  Future<Result<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.post(ApiConstants.orders, data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateOrder(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put('${ApiConstants.orders}/$id', data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> deleteOrder(
    String id,
    String token,
  ) async {
    return apiClient.delete('${ApiConstants.orders}/$id', authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateOrderStatus(
    String id,
    String status,
    String token,
  ) async {
    return apiClient.patch('${ApiConstants.orders}/$id/status', {
      'status': status,
    }, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> getOrderStats(String token) async {
    return apiClient.get(ApiConstants.orderStats, authToken: token);
  }

  // INVENTORY METHODS
  Future<Result<Map<String, dynamic>>> checkInventoryAvailability(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.post(ApiConstants.inventoryCheck, data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> consumeIngredients(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.post(
      ApiConstants.inventoryConsume,
      data,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> getLowStockAlerts(String token) async {
    return apiClient.get(ApiConstants.inventoryLowStock, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> getInventoryDashboard(
    String token,
  ) async {
    return apiClient.get(ApiConstants.inventoryDashboard, authToken: token);
  }

  // SUPPLIER METHODS
  Future<Result<List<dynamic>>> getAllSuppliers({
    bool? active,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (active != null) queryParams['active'] = active.toString();

    return apiClient.getList(
      ApiConstants.suppliers,
      queryParams: queryParams,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> getSupplierById(
    String id,
    String token,
  ) async {
    return apiClient.get('${ApiConstants.suppliers}/$id', authToken: token);
  }

  Future<Result<Map<String, dynamic>>> createSupplier(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.post(ApiConstants.suppliers, data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateSupplier(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put(
      '${ApiConstants.suppliers}/$id',
      data,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> deleteSupplier(
    String id,
    String token,
  ) async {
    return apiClient.delete('${ApiConstants.suppliers}/$id', authToken: token);
  }

  // REVIEW METHODS
  Future<Result<List<dynamic>>> getAllReviews({
    String? user,
    String? menuItem,
    int? rating,
    String? dateFrom,
    String? dateTo,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (user != null) queryParams['user'] = user;
    if (menuItem != null) queryParams['menuItem'] = menuItem;
    if (rating != null) queryParams['rating'] = rating.toString();
    if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
    if (dateTo != null) queryParams['dateTo'] = dateTo;

    return apiClient.getList(
      ApiConstants.reviews,
      queryParams: queryParams,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> createReview(
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.post(ApiConstants.reviews, data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateReview(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put('${ApiConstants.reviews}/$id', data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> deleteReview(
    String id,
    String token,
  ) async {
    return apiClient.delete('${ApiConstants.reviews}/$id', authToken: token);
  }

  // USER METHODS
  Future<Result<List<dynamic>>> getAllUsers(String token) async {
    return apiClient.getList(ApiConstants.users, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> getUserById(
    String id,
    String token,
  ) async {
    return apiClient.get('${ApiConstants.users}/$id', authToken: token);
  }

  Future<Result<Map<String, dynamic>>> updateUser(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    return apiClient.put('${ApiConstants.users}/$id', data, authToken: token);
  }

  Future<Result<Map<String, dynamic>>> deleteUser(
    String id,
    String token,
  ) async {
    return apiClient.delete('${ApiConstants.users}/$id', authToken: token);
  }
}
