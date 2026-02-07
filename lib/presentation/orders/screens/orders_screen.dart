import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/domain/entities/order.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/view_models/orders_view_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late OrdersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Get auth token from AuthManager
    final authManager = context.watch<AuthManager>();
    final token = authManager.token;
    _viewModel = OrdersViewModel(get<OrderRepository>(), token);
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.loadOrders();
    await _viewModel.loadOrderStats();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Management'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            _buildFilterButton(context),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ],
        ),
        body: Consumer<OrdersViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${viewModel.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return _buildOrderList(context, viewModel);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateOrderDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (status) {
        final viewModel = context.read<OrdersViewModel>();
        viewModel.loadOrders(status: status == 'all' ? null : status);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('All Orders')),
        const PopupMenuItem(value: 'pending', child: Text('Pending')),
        const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
        const PopupMenuItem(value: 'preparing', child: Text('Preparing')),
        const PopupMenuItem(value: 'ready', child: Text('Ready')),
        const PopupMenuItem(value: 'served', child: Text('Served')),
        const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
      ],
      icon: const Icon(Icons.filter_list),
    );
  }

  Widget _buildOrderList(BuildContext context, OrdersViewModel viewModel) {
    final orders = viewModel.filteredOrders;

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
            Text(
              'Create your first order',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          if (viewModel.orderStats != null)
            _buildStatsCard(viewModel.orderStats!),
          ...orders.map((order) => _buildOrderCard(order, viewModel)),
        ],
      ),
    );
  }

  Widget _buildStatsCard(OrderStatsEntity stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '\$${stats.dailyEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Revenue',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${stats.todayOrderCount}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Orders',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stats.bestSellingDishes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Best Sellers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stats.bestSellingDishes
                  .take(3)
                  .map(
                    (dish) => ListTile(
                      leading: const Icon(Icons.restaurant, size: 20),
                      title: Text(dish.name),
                      subtitle: Text('${dish.quantity} sold'),
                      trailing: Text('\$${dish.revenue.toStringAsFixed(2)}'),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, OrdersViewModel viewModel) {
    Color statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.shopping_cart, color: Colors.blue),
        title: Text('Order #${order.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.customerName != null)
              Text('Customer: ${order.customerName}'),
            Text('Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
            Text('Items: ${order.items.length}'),
            Text('Date: ${_formatDate(order.orderDate)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                order.statusLabel,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: statusColor,
            ),
            const SizedBox(height: 4),
            PopupMenuButton<String>(
              onSelected: (newStatus) async {
                final result = await viewModel.updateOrderStatus(
                  order.id,
                  newStatus,
                );
                if (result.isFailure) {
                  // Use a global key or handle the error in the ViewModel
                  _showErrorSnackbar(result.failureOrNull!.message);
                }
              },
              itemBuilder: (context) => _buildStatusMenuItems(order.status),
              icon: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
        onTap: () => _showOrderDetails(order),
      ),
    );
  }

  List<PopupMenuItem<String>> _buildStatusMenuItems(String currentStatus) {
    final allStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'served',
      'cancelled',
    ];
    final availableStatuses = allStatuses
        .where((status) => status != currentStatus)
        .toList();

    return availableStatuses.map((status) {
      return PopupMenuItem<String>(
        value: status,
        child: Text(_getStatusLabel(status)),
      );
    }).toList();
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Set Pending';
      case 'confirmed':
        return 'Confirm';
      case 'preparing':
        return 'Start Preparing';
      case 'ready':
        return 'Mark as Ready';
      case 'served':
        return 'Mark as Served';
      case 'cancelled':
        return 'Cancel';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'served':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $message')));
    }
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Customer'),
                subtitle: Text(order.customerName ?? 'Guest'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Amount'),
                subtitle: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Status'),
                subtitle: Text(order.statusLabel),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Order Date'),
                subtitle: Text(_formatDate(order.orderDate)),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant),
                title: const Text('Items'),
                subtitle: Text('${order.items.length} items'),
              ),
              if (order.tableNumber != null)
                ListTile(
                  leading: const Icon(Icons.table_restaurant),
                  title: const Text('Table'),
                  subtitle: Text('Table ${order.tableNumber}'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Order'),
        content: const Text('Order creation feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to order creation screen
              // Navigator.pushNamed(context, '/create-order');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
