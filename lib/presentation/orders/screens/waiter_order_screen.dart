// 📁 waiter_order_screen.dart
///
/// This file defines the waiter order-taking screen, which is the primary interface
/// for restaurant staff to create customer orders. It provides a responsive layout:
/// - On large screens (width > 900px), it displays a two‑column layout with menu
///   on the left and cart on the right.
/// - On smaller screens, the cart is hidden and a floating action button opens
///   a bottom sheet with the cart.
///
/// The screen integrates with [WaiterOrderViewModel] to manage menu items, filters,
/// cart, and order submission. It consumes [AuthManager] for the authentication
/// token and uses dependency injection to obtain [MenuManager] and [OrderManager].

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:restaurant_mobile_app/domain/entities/cart_item.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/menu/managers/menu_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/view_models/waiter_order_view_model.dart';
import 'package:restaurant_mobile_app/presentation/orders/widgets/waiter_menu_item_card.dart';
import 'package:restaurant_mobile_app/presentation/orders/widgets/quick_filters.dart';
import 'package:restaurant_mobile_app/presentation/orders/widgets/filter_dropdowns.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';

// -----------------------------------------------------------------------------
// Public Widget – WaiterOrderScreen
// -----------------------------------------------------------------------------

/// A stateful widget that renders the main order‑taking screen for waiters.
///
/// This screen is the entry point for creating a new order. It displays a
/// responsive layout with a menu panel and a cart panel (or bottom sheet on
/// small screens). It creates and provides a [WaiterOrderViewModel] to its
/// descendants using [ChangeNotifierProvider].
class WaiterOrderScreen extends StatefulWidget {
  const WaiterOrderScreen({super.key});

  @override
  State<WaiterOrderScreen> createState() => _WaiterOrderScreenState();
}

/// The state class for [WaiterOrderScreen].
///
/// Responsible for initialising the [WaiterOrderViewModel] with the required
/// dependencies and authentication token. It builds the scaffold and manages
/// the responsive layout.
class _WaiterOrderScreenState extends State<WaiterOrderScreen> {
  /// The ViewModel that holds the state and business logic for this screen.
  late WaiterOrderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Obtain the authentication token from AuthManager.
    // The token is guaranteed to be non‑null because the user is already
    // authenticated before reaching this screen.
    final token = context.read<AuthManager>().token!;

    // Instantiate the ViewModel with its dependencies from the injector.
    _viewModel = WaiterOrderViewModel(
      menuManager: get<MenuManager>(),
      orderManager: get<OrderManager>(),
      authToken: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel to the entire widget subtree.
    return ChangeNotifierProvider<WaiterOrderViewModel>.value(
      value: _viewModel,
      child: Consumer<WaiterOrderViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Take Order'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: vm.loadMenuItems,
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we are on a large screen (desktop/tablet landscape).
                final isLargeScreen = constraints.maxWidth > 900;

                // Show loading indicator only when first loading and the list is empty.
                if (vm.isLoadingMenu && vm.filteredMenuItems.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Display error state with a retry button.
                if (vm.menuError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${vm.menuError}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: vm.loadMenuItems,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Main content: two‑column layout on large screens, single column otherwise.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu panel always takes the remaining space.
                    Expanded(flex: 2, child: _MenuPanel(vm: vm)),
                    // On large screens, show the cart panel as a fixed‑width sidebar.
                    if (isLargeScreen)
                      Container(
                        width: 360,
                        margin: const EdgeInsets.only(left: 16),
                        child: _CartPanel(vm: vm),
                      ),
                  ],
                );
              },
            ),
            // Floating action button is shown only on small/medium screens.
            floatingActionButton: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) return const SizedBox.shrink();
                return FloatingActionButton(
                  onPressed: () => _showCartBottomSheet(context, vm),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      // Badge showing the number of items in the cart.
                      if (vm.cart.isNotEmpty)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${vm.cart.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Displays the cart as a modal bottom sheet on small screens.
  ///
  /// The bottom sheet is draggable and expands to cover most of the screen.
  /// It reuses the [_CartPanel] widget with a custom scroll controller.
  void _showCartBottomSheet(BuildContext context, WaiterOrderViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return _CartPanel(vm: vm, scrollController: scrollController);
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private Helper Widgets
// -----------------------------------------------------------------------------

/// Displays the menu items in a responsive grid, along with filter controls.
///
/// This panel contains:
/// - [QuickFilters]: category, availability, and chef special chips.
/// - [FilterDropdowns]: additional sorting / filter options.
/// - A [GridView] of [WaiterMenuItemCard] widgets for each filtered item.
class _MenuPanel extends StatelessWidget {
  /// The ViewModel that provides the menu items and filter state.
  final WaiterOrderViewModel vm;

  const _MenuPanel({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal filter chips for quick filtering.
        QuickFilters(vm: vm),
        const SizedBox(height: 16),

        // Dropdown filters (e.g., category, dietary tags).
        FilterDropdowns(vm: vm),
        const SizedBox(height: 16),

        // Grid of menu items, or an empty state message.
        Expanded(
          child: vm.filteredMenuItems.isEmpty
              ? const Center(child: Text('No menu items match your filters'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: vm.filteredMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = vm.filteredMenuItems[index];
                    return WaiterMenuItemCard(
                      item: item,
                      onAddToCart: () => vm.addToCart(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Displays the shopping cart and order details.
///
/// This panel is used both as a sidebar on large screens and as a bottom sheet
/// on small devices. It shows:
/// - A form for table number, customer name, and order notes.
/// - A list of [CartItem]s with quantity controls and special instructions.
/// - Totals (subtotal, tax, total) and a submit button.
class _CartPanel extends StatelessWidget {
  /// The ViewModel that holds the cart state and submission logic.
  final WaiterOrderViewModel vm;

  /// Optional scroll controller – used when this panel is placed inside a
  /// [DraggableScrollableSheet] to enable scrolling.
  final ScrollController? scrollController;

  const _CartPanel({required this.vm, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with item count.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${vm.cart.length} items',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Input fields for order metadata.
          _OrderForm(vm: vm),
          const Divider(height: 24),

          // Cart items list, or empty state.
          Expanded(
            child: vm.cart.isEmpty
                ? const Center(child: Text('No items in cart'))
                : ListView.separated(
                    controller: scrollController,
                    itemCount: vm.cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final cartItem = vm.cart[index];
                      return _CartItemTile(
                        cartItem: cartItem,
                        onQuantityChanged: (q) =>
                            vm.updateQuantity(cartItem.menuItem.id, q),
                        onInstructionsChanged: (i) => vm
                            .updateSpecialInstructions(cartItem.menuItem.id, i),
                        onRemove: () => vm.removeFromCart(cartItem.menuItem.id),
                      );
                    },
                  ),
          ),

          // Totals and submit button, shown only when cart is not empty.
          if (vm.cart.isNotEmpty) ...[
            const Divider(),
            _buildTotalRow('Subtotal', vm.subtotal),
            _buildTotalRow('Tax (10%)', vm.tax),
            const SizedBox(height: 4),
            _buildTotalRow('Total', vm.total, isBold: true),
            const SizedBox(height: 16),
          ],

          // Action buttons.
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.cart.isEmpty || vm.tableNumber == null
                      ? null
                      : () async {
                          try {
                            await vm.submitOrder();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order sent to kitchen!'),
                                ),
                              );
                              Navigator.pushNamed(context, AppRoutes.kds);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Send to Kitchen'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: vm.cart.isEmpty ? null : vm.clearCart,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single row in the totals section.
  ///
  /// If [isBold] is true, both label and amount are displayed in bold.
  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// A form inside the cart panel for capturing order metadata.
///
/// Includes fields for:
/// - Table number (required for order submission)
/// - Customer name (optional)
/// - Order notes (optional)
///
/// All fields are directly bound to the [WaiterOrderViewModel] properties.
class _OrderForm extends StatelessWidget {
  final WaiterOrderViewModel vm;

  const _OrderForm({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: vm.tableNumber?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Table Number *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            vm.tableNumber = int.tryParse(value);
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: vm.customerName ?? '',
          decoration: const InputDecoration(
            labelText: 'Customer Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => vm.customerName = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: vm.orderNotes ?? '',
          decoration: const InputDecoration(
            labelText: 'Order Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) => vm.orderNotes = value,
        ),
      ],
    );
  }
}

/// A tile representing a single item in the shopping cart.
///
/// Displays the item name, quantity controls, total price, and a field
/// for special instructions. Provides callbacks for quantity changes,
/// instruction updates, and removal.
class _CartItemTile extends StatelessWidget {
  /// The cart item to display.
  final CartItem cartItem;

  /// Called when the user increases or decreases the quantity.
  final ValueChanged<int> onQuantityChanged;

  /// Called when the special instructions text field changes.
  final ValueChanged<String> onInstructionsChanged;

  /// Called when the remove icon is tapped.
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onInstructionsChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item name and remove button.
        Row(
          children: [
            Expanded(
              child: Text(
                cartItem.menuItem.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Quantity stepper and item total.
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 16),
              onPressed: () => onQuantityChanged(cartItem.quantity - 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text('${cartItem.quantity}'),
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => onQuantityChanged(cartItem.quantity + 1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Spacer(),
            Text(
              '\$${cartItem.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Special instructions input.
        TextFormField(
          initialValue: cartItem.specialInstructions ?? '',
          decoration: const InputDecoration(
            hintText: 'Special instructions',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(),
          ),
          onChanged: onInstructionsChanged,
        ),
      ],
    );
  }
}
