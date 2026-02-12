// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/kds/widgets/kds_order_card.dart
// Description: Reusable card widget for displaying an order in the
//              Kitchen Display System (KDS). Shows order details,
//              current status, and provides status transition actions.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';

/// A card widget that represents a single order in the Kitchen Display System.
///
/// This widget displays:
///   - Order ID (truncated to first 6 characters).
///   - Current status as a coloured chip.
///   - Customer name and table number (if available).
///   - List of ordered items with quantities and optional special instructions.
///   - A context‑sensitive action button to advance the order to the next stage.
///
/// The widget is stateless and relies on a callback to notify the parent
/// when the status should be updated.
class KDSOrderCard extends StatelessWidget {
  /// The order entity containing all display information.
  final OrderEntity order;

  /// Callback invoked when the user requests a status update.
  ///
  /// The [String] parameter is the new status value (e.g., 'preparing', 'ready').
  /// The parent widget is responsible for handling the actual API call
  /// and state management.
  final Function(String) onStatusUpdate;

  const KDSOrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // Header: Order number and status chip
            // -----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 6)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    statusLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // -----------------------------------------------------------------
            // Customer information (optional)
            // -----------------------------------------------------------------
            if (order.customerName != null || order.tableNumber != null)
              Row(
                children: [
                  if (order.customerName != null)
                    Text('👤 ${order.customerName}'),
                  if (order.customerName != null && order.tableNumber != null)
                    const SizedBox(width: 12),
                  if (order.tableNumber != null)
                    Text('Table ${order.tableNumber}'),
                ],
              ),
            const SizedBox(height: 8),

            // -----------------------------------------------------------------
            // Order items list
            // -----------------------------------------------------------------
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  children: [
                    Text('${item.quantity}× '),
                    Expanded(
                      child: Text(
                        item.menuItemName ?? 'Item',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (item.specialInstructions != null)
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 18),
                        onPressed: () => _showInstructions(
                          context,
                          item.specialInstructions!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // -----------------------------------------------------------------
            // Status transition button
            // -----------------------------------------------------------------
            // Confirmed → Preparing
            if (order.status == OrderStatus.confirmed)
              ElevatedButton.icon(
                onPressed: () => onStatusUpdate('preparing'),
                icon: const Icon(Icons.restaurant),
                label: const Text('Start Preparing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            // Preparing → Ready
            if (order.status == OrderStatus.preparing)
              ElevatedButton.icon(
                onPressed: () => onStatusUpdate('ready'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Ready'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PRIVATE HELPER METHODS
  // -------------------------------------------------------------------------

  /// Returns the appropriate background colour for the status chip.
  ///
  /// - [OrderStatus.confirmed]  → blue
  /// - [OrderStatus.preparing] → orange
  /// - All other statuses       → grey (fallback)
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Returns the human‑readable label for the status chip.
  ///
  /// - [OrderStatus.confirmed]  → 'Confirmed'
  /// - [OrderStatus.preparing] → 'Preparing'
  /// - All other statuses       → [status.label] (default)
  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      default:
        return status.label;
    }
  }

  /// Displays a dialog containing the special instructions for an order item.
  ///
  /// [context]      – build context for showing the dialog.
  /// [instructions] – the special instructions text to display.
  void _showInstructions(BuildContext context, String instructions) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Special Instructions'),
        content: Text(instructions),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
