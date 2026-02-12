import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/kds/view_models/kds_view_model.dart';
import 'package:restaurant_mobile_app/presentation/kds/widgets/kds_order_card.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';

/// Screen that implements the Kitchen Display System (KDS).
///
/// This widget is responsible for displaying all active kitchen orders and
/// allowing staff to update their status. It integrates with:
/// - [AuthManager] to obtain the authentication token.
/// - [OrderManager] (via dependency injection) to perform order operations.
/// - [KDSViewModel] to manage the state and business logic for the KDS view.
///
/// The screen uses a [ChangeNotifierProvider] to expose the view model to its
/// descendant widgets, and listens to state changes via [Consumer].
class KDSScreen extends StatefulWidget {
  const KDSScreen({super.key});

  @override
  State<KDSScreen> createState() => _KDSScreenState();
}

class _KDSScreenState extends State<KDSScreen> {
  late final KDSViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    // Retrieve the current authentication token – it is assumed to be non‑null
    // because this screen is only accessible when the user is logged in.
    final token = context.read<AuthManager>().token!;

    // Instantiate the view model with its required dependencies.
    _viewModel = KDSViewModel(
      get<OrderManager>(), // Resolve OrderManager from the DI container.
      token,
    );

    // Trigger the initial load of kitchen orders.
    _loadOrders();
  }

  /// Initiates an asynchronous load of kitchen orders via the view model.
  ///
  /// This method is called both on initialisation and when the user manually
  /// triggers a refresh (e.g., via the refresh button or pull‑to‑refresh).
  Future<void> _loadOrders() async {
    await _viewModel.loadKitchenOrders();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the existing view model instance to the widget subtree.
    // Using ChangeNotifierProvider.value avoids creating a new instance
    // and ensures that the state is preserved across rebuilds.
    return ChangeNotifierProvider<KDSViewModel>.value(
      value: _viewModel,
      child: _KDSScreenContent(loadOrders: _loadOrders),
    );
  }
}

/// The stateless content part of the KDS screen.
///
/// This widget is rebuilt whenever the [KDSViewModel] notifies listeners.
/// It separates the presentation logic from the initialisation logic defined
/// in the stateful [KDSScreen].
class _KDSScreenContent extends StatelessWidget {
  /// Callback that triggers a reload of orders.
  final Future<void> Function() loadOrders;

  const _KDSScreenContent({required this.loadOrders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display System'),
        actions: [
          // Manual refresh button.
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadOrders),
        ],
      ),
      body: Consumer<KDSViewModel>(
        builder: (context, vm, _) {
          // --- Loading state: show progress indicator only on first load.
          if (vm.isLoading && vm.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Error state: display error message with a retry button.
          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${vm.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // --- Empty state: no active kitchen orders.
          if (vm.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.kitchen, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No active kitchen orders',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // --- Content state: display the list of orders with pull‑to‑refresh.
          return RefreshIndicator(
            onRefresh: loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: vm.orders.length,
              itemBuilder: (context, index) {
                final order = vm.orders[index];
                return KDSOrderCard(
                  order: order,
                  onStatusUpdate: (newStatus) async {
                    // Delegate status update to the view model.
                    await vm.updateOrderStatus(
                      orderId: order.id,
                      status: newStatus,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
