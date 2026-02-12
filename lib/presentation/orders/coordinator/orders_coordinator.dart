// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/orders/coordinators/orders_coordinator.dart
// Description: Navigation and coordination logic for the Orders feature.
//              Provides methods to navigate to order details, creation,
//              and to display status update dialogs and feedback snackbars.
//              Contains placeholder widget implementations that should be
//              moved to dedicated files in a real project.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';
import 'package:restaurant_mobile_app/presentation/orders/screens/order_detail_screen.dart';

/// Coordinates navigation and user feedback for order-related screens.
///
/// This class is responsible for:
///   - Navigating to order details and order creation screens.
///   - Displaying a dialog to update order status.
///   - Showing success/error snackbars.
///
/// It acts as a single source of truth for navigation patterns within the
/// orders feature, promoting consistency and testability.
class OrdersCoordinator {
  const OrdersCoordinator();

  /// Navigates to the order details screen for the given [order].
  ///
  /// Uses [MaterialPageRoute] with a direct builder that passes the
  /// [OrderEntity] to the [OrderDetailScreen] constructor.
  void navigateToOrderDetails(BuildContext context, OrderEntity order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
  }

  /// Navigates to the order creation screen.
  ///
  /// Uses named route [AppRoutes.createOrder].
  void navigateToCreateOrder(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.createOrder);
  }

  /// Displays a dialog for updating the status of the given [order].
  ///
  /// [onStatusUpdate] is a callback that will be invoked with the new status
  /// string when the user confirms the update. The dialog is built using
  /// the [OrderStatusUpdateDialog] widget.
  void showOrderStatusUpdateDialog({
    required BuildContext context,
    required OrderEntity order,
    required Function(String) onStatusUpdate,
  }) {
    showDialog(
      context: context,
      builder: (ctx) =>
          OrderStatusUpdateDialog(order: order, onStatusUpdate: onStatusUpdate),
    );
  }

  /// Displays an error snackbar with the given [message].
  ///
  /// The snackbar has a red background to indicate an error.
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Displays a success snackbar with the given [message].
  ///
  /// The snackbar has a green background to indicate successful operation.
  void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}

// ---------------------------------------------------------------------------
// PLACEHOLDER WIDGETS
// ---------------------------------------------------------------------------
//
// NOTE: The following widgets are temporary placeholders and should be
//       moved to their own separate files when implemented:
//         - lib/presentation/orders/screens/order_detail_screen.dart
//         - lib/presentation/orders/widgets/order_status_update_dialog.dart
//       They are included here only to satisfy imports and allow the
//       coordinator to compile. Replace with full implementations.

/// Placeholder screen for displaying order details.
///
/// **TODO**: Move to separate file and implement full UI.
class OrderDetailsScreen extends StatelessWidget {
  /// The order entity whose details are to be displayed.
  final OrderEntity order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: const Placeholder(),
    );
  }
}

/// Placeholder dialog for updating the status of an order.
///
/// **TODO**: Move to separate file and implement full UI with proper
///           status selection (dropdown, radio buttons, etc.).
class OrderStatusUpdateDialog extends StatelessWidget {
  /// The order whose status is being updated.
  final OrderEntity order;

  /// Callback invoked with the new status when the user confirms.
  final Function(String) onStatusUpdate;

  const OrderStatusUpdateDialog({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Order Status'),
      content: const Placeholder(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Replace with actual selected status.
            onStatusUpdate('confirmed');
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
