import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

/// Concrete implementation of [OrderRepository].
///
/// This class mediates between the domain layer and the remote data source.
/// It accepts requests from use cases, delegates API calls to the
/// [RemoteDataSource], and maps raw JSON responses to domain entities
/// ([OrderEntity], [OrderStatsEntity]).
///
/// All operations return a [Result] type, encapsulating either a successful
/// value or a failure, promoting explicit error handling.
class OrderRepositoryImpl implements OrderRepository {
  /// The remote data source that performs actual HTTP requests.
  final RemoteDataSource _remoteDataSource;

  /// Creates a new [OrderRepositoryImpl] with the required [RemoteDataSource].
  OrderRepositoryImpl(this._remoteDataSource);

  // ---------------------------------------------------------------------------
  // Order retrieval operations
  // ---------------------------------------------------------------------------

  @override
  Future<Result<List<OrderEntity>>> getAllOrders({
    String? status,
    String? customerId,
    OrderType? orderType,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    required String token,
  }) async {
    // Delegate to remote source with parameters mapped to API‑compatible values.
    final result = await _remoteDataSource.getAllOrders(
      status: status,
      customer: customerId,
      orderType: orderType?.value,
      startDate: startDate,
      endDate: endDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
      token: token,
    );

    // Transform the successful raw JSON list into a list of OrderEntity objects.
    return result.map((value) {
      return value
          .map<OrderEntity>((json) => OrderEntity.fromJson(json))
          .toList();
    });
  }

  @override
  Future<Result<OrderEntity>> getOrderById({
    required String orderId,
    required String token,
  }) async {
    final result = await _remoteDataSource.getOrderById(orderId, token);
    // Single JSON object -> single OrderEntity.
    return result.map((value) => OrderEntity.fromJson(value));
  }

  // ---------------------------------------------------------------------------
  // Order mutation operations (create, update, delete)
  // ---------------------------------------------------------------------------

  @override
  Future<Result<OrderEntity>> createOrder({
    required Map<String, dynamic> orderData,
    required String token,
  }) async {
    final result = await _remoteDataSource.createOrder(orderData, token);
    return result.map((value) => OrderEntity.fromJson(value));
  }

  @override
  Future<Result<OrderEntity>> updateOrder({
    required String orderId,
    required Map<String, dynamic> updateData,
    required String token,
  }) async {
    final result = await _remoteDataSource.updateOrder(
      orderId,
      updateData,
      token,
    );
    return result.map((value) => OrderEntity.fromJson(value));
  }

  @override
  Future<Result<void>> deleteOrder({
    required String orderId,
    required String token,
  }) async {
    final result = await _remoteDataSource.deleteOrder(orderId, token);
    // Void result: discard the response value and return a successful Result<void>.
    return result.map((_) {});
  }

  // ---------------------------------------------------------------------------
  // Order status management
  // ---------------------------------------------------------------------------

  @override
  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    required String token,
  }) async {
    final result = await _remoteDataSource.updateOrderStatus(
      orderId,
      status.value,
      token,
    );
    return result.map((value) => OrderEntity.fromJson(value));
  }

  // ---------------------------------------------------------------------------
  // Order analytics
  // ---------------------------------------------------------------------------

  @override
  Future<Result<OrderStatsEntity>> getOrderStats({
    required String token,
  }) async {
    final result = await _remoteDataSource.getOrderStats(token);
    return result.map((value) => OrderStatsEntity.fromJson(value));
  }
}
