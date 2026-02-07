import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/order.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final RemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<Order>>> getAllOrders({
    String? status,
    String? customer,
    String? orderType,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? token,
  }) async {
    final result = await _remoteDataSource.getAllOrders(
      status: status,
      customer: customer,
      orderType: orderType,
      startDate: startDate,
      endDate: endDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
      token: token,
    );

    return result.map((value) {
      final List<dynamic> data = value;
      return data.map((json) => Order.fromJson(json)).toList();
    });
  }

  @override
  Future<Result<Order>> getOrderById(String id, String token) async {
    final result = await _remoteDataSource.getOrderById(id, token);
    return result.map((value) => Order.fromJson(value));
  }

  @override
  Future<Result<Order>> createOrder(
    Map<String, dynamic> data,
    String token,
  ) async {
    final result = await _remoteDataSource.createOrder(data, token);
    return result.map((value) => Order.fromJson(value));
  }

  @override
  Future<Result<Order>> updateOrder(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final result = await _remoteDataSource.updateOrder(id, data, token);
    return result.map((value) => Order.fromJson(value));
  }

  @override
  Future<Result<void>> deleteOrder(String id, String token) async {
    final result = await _remoteDataSource.deleteOrder(id, token);
    return result.map((_) {});
  }

  @override
  Future<Result<Order>> updateOrderStatus(
    String id,
    String status,
    String token,
  ) async {
    final result = await _remoteDataSource.updateOrderStatus(id, status, token);
    return result.map((value) => Order.fromJson(value));
  }

  @override
  Future<Result<OrderStatsEntity>> getOrderStats(String token) async {
    final result = await _remoteDataSource.getOrderStats(token);
    return result.map((value) => OrderStatsEntity.fromJson(value));
  }
}
