import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> getAllOrders({
    String? status,
    String? customer,
    String? orderType,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? token,
  });

  Future<Result<Order>> getOrderById(String id, String token);
  Future<Result<Order>> createOrder(Map<String, dynamic> data, String token);
  Future<Result<Order>> updateOrder(
    String id,
    Map<String, dynamic> data,
    String token,
  );
  Future<Result<void>> deleteOrder(String id, String token);
  Future<Result<Order>> updateOrderStatus(
    String id,
    String status,
    String token,
  );
  Future<Result<OrderStatsEntity>> getOrderStats(String token);
}
