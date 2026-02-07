import 'package:flutter/foundation.dart';
import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final String? _authToken;

  OrdersViewModel(this._orderRepository, [this._authToken]);

  List<Order> _orders = [];
  OrderStatsEntity? _orderStats;
  bool _isLoading = false;
  String? _errorMessage;
  String? _filterStatus;

  List<Order> get orders => _orders;
  OrderStatsEntity? get orderStats => _orderStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filterStatus => _filterStatus;

  List<Order> get filteredOrders {
    if (_filterStatus == null || _filterStatus!.isEmpty) {
      return _orders;
    }
    return _orders.where((order) => order.status == _filterStatus).toList();
  }

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
      final result = await _orderRepository.getAllOrders(
        status: status,
        token: authToken,
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

  Future<void> loadOrderStats() async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderRepository.getOrderStats(authToken);

      _isLoading = false;

      if (result.isSuccess) {
        _orderStats = result.valueOrNull;
      }
    } catch (e) {
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<Result<Order>> createOrder(Map<String, dynamic> orderData) async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) {
      return ResultFailure(AuthenticationFailure('Authentication required'));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _orderRepository.createOrder(orderData, authToken);

      _isLoading = false;
      notifyListeners();

      if (result.isSuccess) {
        final newOrder = result.valueOrNull;
        if (newOrder != null) {
          _orders.insert(0, newOrder);
          notifyListeners();
        }
      }

      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return ResultFailure(GenericFailure('Failed to create order: $e'));
    }
  }

  Future<Result<Order>> updateOrderStatus(String orderId, String status) async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) {
      return ResultFailure(AuthenticationFailure('Authentication required'));
    }

    try {
      final result = await _orderRepository.updateOrderStatus(
        orderId,
        status,
        authToken,
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
      return ResultFailure(
        GenericFailure('Failed to update order status: $e'),
      );
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _orders = [];
    _orderStats = null;
    _filterStatus = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
