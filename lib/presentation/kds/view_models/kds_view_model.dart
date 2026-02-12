import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';

/// ViewModel for the Kitchen Display System (KDS) screen.
///
/// This [ChangeNotifier] is responsible for managing the state of the KDS
/// screen, including fetching and displaying kitchen orders, handling loading
/// and error states, and updating order statuses.
///
/// It communicates with the [OrderManager] to perform actual order operations
/// and uses the provided authentication token for all API requests.
class KDSViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  /// The domain layer manager responsible for order-related use cases.
  final OrderManager _orderManager;

  /// The authentication token required for authenticated API calls.
  final String _authToken;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// List of orders currently displayed in the KDS.
  List<OrderEntity> _orders = [];

  /// Indicates whether an asynchronous operation (e.g., loading orders) is
  /// currently in progress.
  bool _isLoading = false;

  /// Stores the most recent error message, or `null` if no error occurred.
  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a new [KDSViewModel] with the required dependencies.
  ///
  /// - [_orderManager]: Used to retrieve and update orders.
  /// - [_authToken]: Bearer token for authenticating API requests.
  KDSViewModel(this._orderManager, this._authToken);

  // ---------------------------------------------------------------------------
  // Getters (Exposed State)
  // ---------------------------------------------------------------------------

  /// The list of kitchen orders (filtered for 'confirmed' and 'preparing'
  /// statuses), sorted with the most recent orders first.
  List<OrderEntity> get orders => _orders;

  /// `true` if a network operation is currently being performed.
  bool get isLoading => _isLoading;

  /// The current error message, or `null` if the last operation succeeded.
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  /// Loads all orders relevant to the kitchen (statuses 'confirmed' and
  /// 'preparing') and updates the internal state.
  ///
  /// This method:
  /// - Sets [_isLoading] to `true` and clears any previous error.
  /// - Calls [_orderManager.getOrders] twice, once for each status.
  /// - Combines the successful results, ignoring any individual failure.
  /// - Sorts the combined list by [OrderEntity.orderDate] descending.
  /// - Updates [_orders] and resets [_isLoading] / [_errorMessage].
  ///
  /// Listeners are notified both at the beginning and at the end of the
  /// operation.
  Future<void> loadKitchenOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch orders with status 'confirmed'.
      final confirmedResult = await _orderManager.getOrders(
        token: _authToken,
        status: 'confirmed',
      );

      // Fetch orders with status 'preparing'.
      final preparingResult = await _orderManager.getOrders(
        token: _authToken,
        status: 'preparing',
      );

      final List<OrderEntity> combined = [];

      // Add successful results from the confirmed query.
      if (confirmedResult.isSuccess) {
        combined.addAll(confirmedResult.valueOrNull ?? []);
      } else {
        _errorMessage = confirmedResult.failureOrNull?.message;
      }

      // Add successful results from the preparing query.
      if (preparingResult.isSuccess) {
        combined.addAll(preparingResult.valueOrNull ?? []);
      }

      // Sort orders by date, newest first.
      combined.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      _orders = combined;
    } catch (e) {
      // Catch any unexpected exceptions (e.g., network errors).
      _errorMessage = 'Failed to load kitchen orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the status of a specific order and refreshes the order list.
  ///
  /// Delegates the update operation to [_orderManager.updateOrderStatus].
  /// If the update succeeds, the order list is automatically reloaded to
  /// reflect the change. The method returns the [Result] from the manager,
  /// which contains either the updated [OrderEntity] or a [Failure].
  ///
  /// - [orderId]: The unique identifier of the order to update.
  /// - [status]: The new status string (e.g., 'preparing', 'ready').
  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final result = await _orderManager.updateOrderStatus(
      orderId: orderId,
      status: status,
      token: _authToken,
    );

    // If the update was successful, refresh the order list.
    if (result.isSuccess) {
      await loadKitchenOrders();
    }

    return result;
  }
}
