// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/orders/widgets/order_card.dart
// Description: A card widget that displays a summary of an order.
//              Used in order list screens to show key information and
//              provide quick access to status updates and navigation.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';

/// A compact card widget representing a single order in a list.
///
/// Displays:
///   - Truncated order ID (first 8 characters).
///   - Customer name (if available).
///   - Total amount formatted as currency.
///   - Number of items in the order.
///   - Order date and time.
///   - Current status as a coloured chip.
///   - A popup menu to change the order status.
///
/// The card is tappable; [onTap] is called when the card is pressed.
/// Status changes are propagated via [onStatusUpdate] callback.
class OrderCard extends StatelessWidget {
  /// The order entity containing all data to display.
  final OrderEntity order;

  /// Callback invoked when the card is tapped.
  ///
  /// Typically used to navigate to the order details screen.
  final VoidCallback onTap;

  /// Callback invoked when a new status is selected from the popup menu.
  ///
  /// The [String] parameter is the new status value (e.g., 'confirmed').
  final Function(String) onStatusUpdate;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

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
        trailing: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status chip – colour reflects the current status.
              Chip(
                label: Text(
                  order.status.label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: statusColor,
              ),
              // Popup menu to change status.
              SizedBox(
                height: 20,
                child: PopupMenuButton<String>(
                  onSelected: (newStatus) => onStatusUpdate(newStatus),
                  itemBuilder: (context) =>
                      _buildStatusMenuItems(order.status.value),
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE HELPER METHODS
  // -------------------------------------------------------------------------

  /// Builds the list of popup menu items for status transitions.
  ///
  /// [currentStatus] – the current status value; items for this status
  ///                   are excluded so the user cannot select the same status.
  ///
  /// Returns a list of [PopupMenuItem] widgets, each with a display label
  /// derived from the status value via [_getStatusLabel].
  List<PopupMenuItem<String>> _buildStatusMenuItems(String currentStatus) {
    const allStatuses = [
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

  /// Returns a human‑readable label for a status menu item.
  ///
  /// The label describes the action that will be performed when the item
  /// is selected (e.g., "Confirm", "Mark as Ready").
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

  /// Returns the appropriate background colour for a status chip.
  ///
  /// Colours are chosen to convey the meaning of each status:
  ///   - pending   : orange (awaiting action)
  ///   - confirmed : blue   (acknowledged)
  ///   - preparing : blue   (in progress)
  ///   - ready     : green  (completed)
  ///   - served    : purple (finalised)
  ///   - cancelled : red    (terminated)
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.served:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Formats a [DateTime] object into a compact string.
  ///
  /// Format: `dd/mm/yyyy hh:mm` (24‑hour clock).
  /// Minutes are always two digits (zero‑padded).
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
