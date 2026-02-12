import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';

abstract class OrderRepository {
  Future<Result<List<OrderEntity>>> getAllOrders({
    String? status,
    String? customerId,
    OrderType? orderType,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    required String token,
  });

  Future<Result<OrderEntity>> getOrderById({
    required String orderId,
    required String token,
  });

  Future<Result<OrderEntity>> createOrder({
    required Map<String, dynamic> orderData,
    required String token,
  });

  Future<Result<OrderEntity>> updateOrder({
    required String orderId,
    required Map<String, dynamic> updateData,
    required String token,
  });

  Future<Result<void>> deleteOrder({
    required String orderId,
    required String token,
  });

  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    required String token,
  });

  Future<Result<OrderStatsEntity>> getOrderStats({required String token});
}
