// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/orders/view_models/orders_view_model.dart
// Description: ViewModel for the Orders feature. Manages the state of orders,
//              order statistics, filtering, and loading states. Implements
//              ChangeNotifier to notify listeners of state changes.
//              Interacts with OrderManager to perform asynchronous operations.
// *****************************************************************************

import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';

/// ViewModel responsible for order list management, filtering, and statistics.
///
/// This class holds the state for the orders screen and exposes:
///   - List of all orders or filtered by status.
///   - Order statistics for dashboard.
///   - Loading and error states.
///
/// It communicates with [OrderManager] to fetch orders and update statuses.
/// All operations are asynchronous and the state is updated via `notifyListeners()`.
class OrdersViewModel extends ChangeNotifier {
  // -------------------------------------------------------------------------
  // DEPENDENCIES
  // -------------------------------------------------------------------------

  /// Business logic manager for order operations.
  final OrderManager _orderManager;

  /// Authentication token used for authorized API requests.
  /// May be null if the user is not authenticated.
  final String? _authToken;

  // -------------------------------------------------------------------------
  // PRIVATE STATE FIELDS
  // -------------------------------------------------------------------------

  /// Complete list of orders fetched from the server.
  List<OrderEntity> _orders = [];

  /// Order statistics (daily revenue, counts, etc.).
  OrderStatsEntity? _orderStats;

  /// Indicates whether an asynchronous operation is in progress.
  bool _isLoading = false;

  /// Error message to display; `null` if no error.
  String? _errorMessage;

  /// Current active filter by order status.
  /// If `null` or empty, no filter is applied.
  String? _filterStatus;

  // -------------------------------------------------------------------------
  // CONSTRUCTOR
  // -------------------------------------------------------------------------

  /// Creates an instance of [OrdersViewModel] with the required [orderManager]
  /// and an optional [authToken].
  OrdersViewModel(this._orderManager, [this._authToken]);

  // -------------------------------------------------------------------------
  // PUBLIC GETTERS
  // -------------------------------------------------------------------------

  /// Returns the complete unfiltered list of orders.
  List<OrderEntity> get orders => _orders;

  /// Returns the order statistics, or `null` if not loaded.
  OrderStatsEntity? get orderStats => _orderStats;

  /// `true` if a network operation is currently executing.
  bool get isLoading => _isLoading;

  /// Error message, or `null` if no error.
  String? get errorMessage => _errorMessage;

  /// Current status filter value.
  String? get filterStatus => _filterStatus;

  /// Returns the list of orders filtered by the current [_filterStatus].
  ///
  /// If no filter is set, returns all orders.
  List<OrderEntity> get filteredOrders {
    if (_filterStatus == null || _filterStatus!.isEmpty) {
      return _orders;
    }
    return _orders
        .where((order) => order.status.value == _filterStatus)
        .toList();
  }

  // -------------------------------------------------------------------------
  // PUBLIC METHODS – DATA FETCHING
  // -------------------------------------------------------------------------

  /// Loads orders from the server, optionally filtered by [status].
  ///
  /// Sets loading state, clears previous errors, and updates [_orders]
  /// and [_filterStatus]. Notifies listeners on completion.
  ///
  /// If the authentication token is missing, sets an error and returns early.
  Future<void> loadOrders({String? status}) async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) {
      _errorMessage = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _filterStatus = status;
    notifyListeners();

    try {
      final result = await _orderManager.getOrders(
        token: authToken,
        status: status,
      );

      _isLoading = false;

      if (result.isSuccess) {
        _orders = result.valueOrNull ?? [];
        _errorMessage = null;
      } else {
        _errorMessage = result.failureOrNull?.message;
        _orders = [];
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load orders: $e';
    }

    notifyListeners();
  }

  /// Loads order statistics (e.g., daily earnings, order count) from the server.
  ///
  /// If the authentication token is missing, the method silently returns.
  /// On success, updates [_orderStats]; on failure, leaves it unchanged.
  /// Notifies listeners when loading starts and after completion.
  Future<void> loadOrderStats() async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderManager.getOrderStats(token: authToken);
      _isLoading = false;

      if (result.isSuccess) {
        _orderStats = result.valueOrNull;
      }
    } catch (e) {
      _isLoading = false;
    }

    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // PUBLIC METHODS – MUTATIONS
  // -------------------------------------------------------------------------

  /// Updates the status of a specific order.
  ///
  /// [orderId] – the unique identifier of the order.
  /// [status]  – the new status string (e.g., 'confirmed', 'preparing', 'ready').
  ///
  /// Returns a [Result] containing the updated [OrderEntity] on success,
  /// or a [Failure] on error.
  ///
  /// If the update succeeds, the local [_orders] list is updated with the
  /// modified order and listeners are notified.
  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) {
      return ResultFailure(AuthenticationFailure('Authentication required'));
    }

    try {
      final result = await _orderManager.updateOrderStatus(
        orderId: orderId,
        status: status,
        token: authToken,
      );

      if (result.isSuccess) {
        final updatedOrder = result.valueOrNull;
        if (updatedOrder != null) {
          final index = _orders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            _orders[index] = updatedOrder;
            notifyListeners();
          }
        }
      }

      return result;
    } catch (e) {
      return ResultFailure(GenericFailure('Failed to update order status: $e'));
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC METHODS – STATE MANAGEMENT
  // -------------------------------------------------------------------------

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets the ViewModel to its initial state.
  ///
  /// Clears all orders, statistics, filter, error, and loading flag.
  void reset() {
    _orders = [];
    _orderStats = null;
    _filterStatus = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
