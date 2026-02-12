import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/constants/api_constants.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/core/network/api_client.dart';

class RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSource({required this.apiClient});

  // ========== AUTH ==========
  Future<Result<Map<String, dynamic>>> login(
    Map<String, dynamic> credentials,
  ) => apiClient.post(ApiConstants.authLogin, credentials);

  Future<Result<Map<String, dynamic>>> register(Map<String, dynamic> data) =>
      apiClient.post(ApiConstants.authRegister, data);

  Future<Result<Map<String, dynamic>>> getCurrentUser(String token) =>
      apiClient.get(ApiConstants.authMe, authToken: token);

  Future<Result<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put(ApiConstants.authUpdate, data, authToken: token);

  Future<Result<Map<String, dynamic>>> changePassword(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put(ApiConstants.authChangePassword, data, authToken: token);

  // ========== MENU ==========
  Future<Result<List<dynamic>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    final queryParams = _buildQueryParams({
      if (category != null) 'category': category,
      if (dietary != null) 'dietary': dietary,
      if (search != null) 'search': search,
      if (available != null) 'available': available.toString(),
      if (chefSpecial != null) 'chefSpecial': chefSpecial.toString(),
    });

    final result = await apiClient.get(
      ApiConstants.menu,
      queryParams: queryParams,
      authToken: token,
    );

    return _extractList(result, field: 'data'); // adjust field name as needed
  }

  Future<Result<Map<String, dynamic>>> getMenuItemById(
    String id,
    String? token,
  ) => apiClient.get('${ApiConstants.menu}/$id', authToken: token);

  Future<Result<Map<String, dynamic>>> createMenuItem(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.post(ApiConstants.menu, data, authToken: token);

  Future<Result<Map<String, dynamic>>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put('${ApiConstants.menu}/$id', data, authToken: token);

  Future<Result<Map<String, dynamic>>> deleteMenuItem(
    String id,
    String token,
  ) => apiClient.delete('${ApiConstants.menu}/$id', authToken: token);

  // ========== CATEGORIES ==========
  Future<Result<List<dynamic>>> getAllCategories({
    String? name,
    bool? isActive,
    String? token,
  }) async {
    final queryParams = _buildQueryParams({
      if (name != null) 'name': name,
      if (isActive != null) 'isActive': isActive.toString(),
    });

    final result = await apiClient.get(
      ApiConstants.categories,
      queryParams: queryParams,
      authToken: token,
    );

    return _extractList(result, field: 'categories');
  }

  // ========== ORDERS ==========
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
    final queryParams = _buildQueryParams({
      if (status != null) 'status': status,
      if (customer != null) 'customer': customer,
      if (orderType != null) 'orderType': orderType,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (minAmount != null) 'minAmount': minAmount.toString(),
      if (maxAmount != null) 'maxAmount': maxAmount.toString(),
    });

    final result = await apiClient.get(
      ApiConstants.orders,
      queryParams: queryParams,
      authToken: token,
    );

    return _extractList(result, field: 'orders');
  }

  Future<Result<Map<String, dynamic>>> getOrderById(String id, String token) =>
      apiClient.get('${ApiConstants.orders}/$id', authToken: token);

  Future<Result<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.post(ApiConstants.orders, data, authToken: token);

  Future<Result<Map<String, dynamic>>> updateOrder(
    String id,
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put('${ApiConstants.orders}/$id', data, authToken: token);

  Future<Result<Map<String, dynamic>>> deleteOrder(String id, String token) =>
      apiClient.delete('${ApiConstants.orders}/$id', authToken: token);

  Future<Result<Map<String, dynamic>>> updateOrderStatus(
    String id,
    String status,
    String token,
  ) => apiClient.patch('${ApiConstants.orders}/$id/status', {
    'status': status,
  }, authToken: token);

  Future<Result<Map<String, dynamic>>> getOrderStats(String token) =>
      apiClient.get(ApiConstants.orderStats, authToken: token);

  // ========== INVENTORY ==========
  Future<Result<Map<String, dynamic>>> checkInventoryAvailability(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.post(ApiConstants.inventoryCheck, data, authToken: token);

  Future<Result<Map<String, dynamic>>> consumeIngredients(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.post(ApiConstants.inventoryConsume, data, authToken: token);

  Future<Result<Map<String, dynamic>>> getLowStockAlerts(String token) =>
      apiClient.get(ApiConstants.inventoryLowStock, authToken: token);

  Future<Result<Map<String, dynamic>>> getInventoryDashboard(String token) =>
      apiClient.get(ApiConstants.inventoryDashboard, authToken: token);

  // ========== SUPPLIERS ==========
  Future<Result<List<dynamic>>> getAllSuppliers({
    bool? active,
    String? token,
  }) async {
    final queryParams = _buildQueryParams({
      if (active != null) 'active': active.toString(),
    });

    final result = await apiClient.get(
      ApiConstants.suppliers,
      queryParams: queryParams,
      authToken: token,
    );

    return _extractList(result, field: 'suppliers');
  }

  Future<Result<Map<String, dynamic>>> getSupplierById(
    String id,
    String token,
  ) => apiClient.get('${ApiConstants.suppliers}/$id', authToken: token);

  Future<Result<Map<String, dynamic>>> createSupplier(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.post(ApiConstants.suppliers, data, authToken: token);

  Future<Result<Map<String, dynamic>>> updateSupplier(
    String id,
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put('${ApiConstants.suppliers}/$id', data, authToken: token);

  Future<Result<Map<String, dynamic>>> deleteSupplier(
    String id,
    String token,
  ) => apiClient.delete('${ApiConstants.suppliers}/$id', authToken: token);

  // ========== REVIEWS ==========
  Future<Result<List<dynamic>>> getAllReviews({
    String? user,
    String? menuItem,
    int? rating,
    String? dateFrom,
    String? dateTo,
    String? token,
  }) async {
    final queryParams = _buildQueryParams({
      if (user != null) 'user': user,
      if (menuItem != null) 'menuItem': menuItem,
      if (rating != null) 'rating': rating.toString(),
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    });

    final result = await apiClient.get(
      ApiConstants.reviews,
      queryParams: queryParams,
      authToken: token,
    );

    return _extractList(result, field: 'reviews');
  }

  Future<Result<Map<String, dynamic>>> createReview(
    Map<String, dynamic> data,
    String token,
  ) => apiClient.post(ApiConstants.reviews, data, authToken: token);

  Future<Result<Map<String, dynamic>>> updateReview(
    String id,
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put('${ApiConstants.reviews}/$id', data, authToken: token);

  Future<Result<Map<String, dynamic>>> deleteReview(String id, String token) =>
      apiClient.delete('${ApiConstants.reviews}/$id', authToken: token);

  // ========== USERS ==========
  Future<Result<List<dynamic>>> getAllUsers(String token) async {
    final result = await apiClient.get(ApiConstants.users, authToken: token);
    return _extractList(result, field: 'users');
  }

  Future<Result<Map<String, dynamic>>> getUserById(String id, String token) =>
      apiClient.get('${ApiConstants.users}/$id', authToken: token);

  Future<Result<Map<String, dynamic>>> updateUser(
    String id,
    Map<String, dynamic> data,
    String token,
  ) => apiClient.put('${ApiConstants.users}/$id', data, authToken: token);

  Future<Result<Map<String, dynamic>>> deleteUser(String id, String token) =>
      apiClient.delete('${ApiConstants.users}/$id', authToken: token);

  // ========== PRIVATE HELPERS ==========

  /// Builds a non‑nullable query parameter map for [apiClient.get].
  Map<String, String>? _buildQueryParams(Map<String, String>? params) {
    if (params == null || params.isEmpty) return null;
    return params;
  }

  /// Extracts a list from a successful [Result] that contains a Map.
  /// Tries common field names: [field], 'data', or the raw Map if it is a List.
  /// Extracts a list from a successful [Result] that contains a Map.
  /// Tries the exact [field] name, then falls back to 'data', then logs and returns empty list.
  Result<List<dynamic>> _extractList(
    Result<Map<String, dynamic>> result, {
    required String field,
  }) {
    return result.fold(
      onSuccess: (json) {
        // 1. Try the exact field name (e.g. 'users', 'orders', etc.)
        if (json.containsKey(field) && json[field] is List) {
          return Success<List<dynamic>>(json[field] as List<dynamic>);
        }
        // 2. Fallback to common 'data' field
        if (json.containsKey('data') && json['data'] is List) {
          return Success<List<dynamic>>(json['data'] as List<dynamic>);
        }
        // 3. Unexpected – log and return empty list
        debugPrint('Unexpected response format for $field: $json');
        return const Success<List<dynamic>>(<dynamic>[]);
      },
      onFailure: (failure) => ResultFailure<List<dynamic>>(failure),
    );
  }
}
