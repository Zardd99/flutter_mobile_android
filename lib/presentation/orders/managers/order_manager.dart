import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/domain/use_cases/create_order_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/get_order_stats_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/get_orders_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/update_order_status_use_case.dart';

/// Manages order-related operations at the presentation layer.
///
/// This class acts as a facade that coordinates multiple use cases
/// ([GetOrdersUseCase], [CreateOrderUseCase], [GetOrderStatsUseCase],
/// [UpdateOrderStatusUseCase]) and exposes a clean, simplified API
/// for ViewModels or other presentation components.
///
/// It decouples the UI from the concrete use case implementations and
/// centralises error handling and result transformation (if any). All
/// methods return a [Result] object that encapsulates either a successful
/// value or a failure with detailed error information.
class OrderManager {
  // ---------------------------------------------------------------------------
  // Private fields (dependencies)
  // ---------------------------------------------------------------------------

  /// Use case responsible for retrieving a list of orders.
  final GetOrdersUseCase _getOrdersUseCase;

  /// Use case responsible for retrieving order statistics.
  final GetOrderStatsUseCase _getOrderStatsUseCase;

  /// Use case responsible for updating the status of an existing order.
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  /// Use case responsible for creating a new order.
  final CreateOrderUseCase _createOrderUseCase;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates an [OrderManager] with the required use case dependencies.
  ///
  /// All parameters are mandatory and should be obtained from the dependency
  /// injection container (e.g., `get_it`).
  OrderManager({
    required GetOrdersUseCase getOrdersUseCase,
    required GetOrderStatsUseCase getOrderStatsUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required CreateOrderUseCase createOrderUseCase,
  }) : _getOrdersUseCase = getOrdersUseCase,
       _getOrderStatsUseCase = getOrderStatsUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       _createOrderUseCase = createOrderUseCase;

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Retrieves a list of orders, optionally filtered by status.
  ///
  /// - [token]: Authentication token required for the request.
  /// - [status]: (Optional) If provided, only orders with this status are returned.
  ///
  /// Returns a [Result] containing a [List<OrderEntity>] on success,
  /// or a [Failure] on error.
  Future<Result<List<OrderEntity>>> getOrders({
    required String token,
    String? status,
  }) async {
    return await _getOrdersUseCase.execute(token: token, status: status);
  }

  /// Creates a new order with the provided data.
  ///
  /// - [orderData]: A map containing the order details (items, customer info, etc.).
  /// - [token]: Authentication token required for the request.
  ///
  /// Returns a [Result] containing the created [OrderEntity] on success,
  /// or a [Failure] on error.
  Future<Result<OrderEntity>> createOrder({
    required Map<String, dynamic> orderData,
    required String token,
  }) {
    return _createOrderUseCase.execute(orderData: orderData, token: token);
  }

  /// Retrieves aggregated statistics about orders.
  ///
  /// - [token]: Authentication token required for the request.
  ///
  /// Returns a [Result] containing an [OrderStatsEntity] on success,
  /// or a [Failure] on error.
  Future<Result<OrderStatsEntity>> getOrderStats({
    required String token,
  }) async {
    return await _getOrderStatsUseCase.execute(token: token);
  }

  /// Updates the status of a specific order.
  ///
  /// - [orderId]: Unique identifier of the order to update.
  /// - [status]: New status value (e.g., 'confirmed', 'preparing', 'ready').
  /// - [token]: Authentication token required for the request.
  ///
  /// Returns a [Result] containing the updated [OrderEntity] on success,
  /// or a [Failure] on error.
  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
    required String token,
  }) async {
    return await _updateOrderStatusUseCase.execute(
      orderId: orderId,
      status: status,
      token: token,
    );
  }
}
