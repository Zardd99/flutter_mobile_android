import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/coordinator/orders_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/view_models/orders_view_model.dart';
import 'package:restaurant_mobile_app/presentation/orders/widgets/order_card.dart';
import 'package:restaurant_mobile_app/presentation/orders/widgets/order_filter_button.dart';
import 'package:restaurant_mobile_app/presentation/orders/widgets/order_stats_card.dart';

// -----------------------------------------------------------------------------
// Screen: OrdersScreen (Stateful)
// -----------------------------------------------------------------------------

/// The main screen for order management.
///
/// This screen displays a list of orders, a statistics card (if available),
/// and provides controls for filtering, refreshing, and creating new orders.
///
/// It initialises the [OrdersViewModel] with the required dependencies
/// ([OrderManager] from DI and the authentication token from [AuthManager])
/// and triggers the initial data load. The actual UI is delegated to the
/// stateless [_OrdersScreenContent] widget, which observes the view model
/// and reacts to state changes.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

/// State class for [OrdersScreen].
///
/// Responsible for:
/// - Creating the [OrdersViewModel] once.
/// - Triggering the initial data load (orders + stats) exactly once.
/// - Providing the view model to the widget subtree via [ChangeNotifierProvider].
class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersViewModel _viewModel;

  /// Flag to ensure that data is loaded only once when the screen becomes
  /// dependent on inherited widgets (see [didChangeDependencies]).
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();

    // Obtain the current authentication token from the AuthManager.
    // This screen is assumed to be accessible only when the user is logged in,
    // so token is expected to be non‑null. If null, the app will crash – this
    // is intentional as it indicates a serious navigation / auth flow bug.
    final authToken = context.read<AuthManager>().token!;

    // Instantiate the view model with its dependencies.
    _viewModel = OrdersViewModel(
      get<OrderManager>(), // Resolved from the dependency injection container.
      authToken,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load data only once, after the context is fully wired to providers.
    if (!_dataLoaded) {
      _dataLoaded = true;
      _loadData();
    }
  }

  /// Triggers the asynchronous loading of orders and order statistics.
  Future<void> _loadData() async {
    await _viewModel.loadOrders();
    await _viewModel.loadOrderStats();
  }

  @override
  Widget build(BuildContext context) {
    // Expose the existing view model instance to the subtree.
    // Using .value prevents unnecessary re‑creation of the provider.
    return ChangeNotifierProvider<OrdersViewModel>.value(
      value: _viewModel,
      child: _OrdersScreenContent(loadData: _loadData),
    );
  }
}

// -----------------------------------------------------------------------------
// Content Widget (Stateless)
// -----------------------------------------------------------------------------

/// The stateless UI part of the orders screen.
///
/// This widget observes the [OrdersViewModel] via [Consumer] and rebuilds
/// whenever the model notifies listeners. It separates the presentation logic
/// from the initialisation logic defined in the stateful [OrdersScreen].
///
/// It receives a [loadData] callback from its parent to enable refresh
/// operations (pull‑to‑refresh, retry, manual refresh button).
class _OrdersScreenContent extends StatelessWidget {
  /// Callback that reloads orders and statistics.
  final Future<void> Function() loadData;

  const _OrdersScreenContent({required this.loadData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrdersViewModel>(context);
    final coordinator = const OrdersCoordinator();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          // Filter button – delegates filter changes to the view model.
          OrderFilterButton(
            onFilterChanged: (status) => viewModel.loadOrders(status: status),
          ),
          // Manual refresh button.
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
        ],
      ),
      body: Consumer<OrdersViewModel>(
        builder: (context, vm, _) {
          // ----- Loading state (first load) -----
          if (vm.isLoading && vm.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ----- Error state -----
          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${vm.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ----- Success / content state -----
          return _buildOrderList(context, vm, coordinator);
        },
      ),
      // Floating action button to create a new order.
      floatingActionButton: FloatingActionButton(
        onPressed: () => coordinator.navigateToCreateOrder(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the main list of orders.
  ///
  /// If [viewModel.orderStats] is not null, a [OrderStatsCard] is inserted
  /// at the top of the list. Otherwise, the list starts directly with the
  /// first order.
  ///
  /// The list supports pull‑to‑refresh via [RefreshIndicator], and each
  /// [OrderCard] is tappable and provides a status update callback.
  Widget _buildOrderList(
    BuildContext context,
    OrdersViewModel viewModel,
    OrdersCoordinator coordinator,
  ) {
    final orders = viewModel.filteredOrders;

    // ----- Empty state -----
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ----- List with optional stats card -----
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.builder(
        // If stats are present, we need one extra item at the top.
        itemCount: orders.length + (viewModel.orderStats != null ? 1 : 0),
        itemBuilder: (context, index) {
          // First item: order statistics card (if available)
          if (viewModel.orderStats != null && index == 0) {
            return OrderStatsCard(stats: viewModel.orderStats!);
          }

          // Adjust index if stats card is present.
          final orderIndex = viewModel.orderStats != null ? index - 1 : index;
          final order = orders[orderIndex];

          return OrderCard(
            order: order,
            onTap: () => coordinator.navigateToOrderDetails(context, order),
            onStatusUpdate: (newStatus) async {
              final result = await viewModel.updateOrderStatus(
                orderId: order.id,
                status: newStatus,
              );

              // Show appropriate feedback based on the result.
              result.fold(
                onSuccess: (_) => coordinator.showSuccessSnackbar(
                  context,
                  'Status updated successfully',
                ),
                onFailure: (failure) =>
                    coordinator.showErrorSnackbar(context, failure.message),
              );
            },
          );
        },
      ),
    );
  }
}
