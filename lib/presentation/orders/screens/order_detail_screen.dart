// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/orders/screens/order_detail_screen.dart
// Description: Screen that displays detailed information for a specific order.
//              Currently contains a discrepancy between constructor parameter
//              and route argument handling. See TODO comments.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';

/// Screen responsible for displaying the full details of a single order.
///
/// This screen is intended to show comprehensive order information including
/// customer details, ordered items, pricing, status history, and timestamps.
/// However, the current implementation is incomplete and contains a logical
/// inconsistency (see [build] method).
///
/// The screen can be instantiated in two ways:
/// 1. Directly via constructor, passing an [OrderEntity] object.
/// 2. Via named route, passing the order ID as a String argument.
///
/// ⚠️ **KNOWN ISSUE**: The current implementation mixes both approaches.
///    The constructor receives an [order] but the build method ignores it
///    and attempts to read the order ID from route arguments.
///    This needs to be resolved by choosing one consistent pattern.
class OrderDetailScreen extends StatelessWidget {
  /// The order entity to display.
  ///
  /// This parameter is currently **ignored** in the build method.
  /// See [build] for the current (incorrect) implementation.
  final OrderEntity order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------------
    // ⚠️ ISSUE: Inconsistent data source
    // -----------------------------------------------------------------------
    // The line below retrieves the order ID from the route arguments,
    // completely disregarding the [order] passed via constructor.
    // This creates a mismatch: the screen is built with an order object
    // but displays an ID retrieved separately.
    //
    // TODO: Refactor to use a single source of truth.
    //       Option A: Remove constructor parameter and rely solely on route args.
    //       Option B: Remove route argument reading and use the provided [order].
    //       Option C: Accept both but prioritise one with clear precedence.
    // -----------------------------------------------------------------------
    final orderId = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        // TODO: Add actions for editing status, contacting customer, etc.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            orderId.isEmpty ? 'No order id provided' : 'Order ID: $orderId',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      // TODO: Implement full order detail UI with:
      //       - Customer information card
      //       - Order items list with quantities and special instructions
      //       - Price breakdown (subtotal, tax, total)
      //       - Status timeline / current status chip
      //       - Action buttons (update status, reorder, contact)
    );
  }
}

// ---------------------------------------------------------------------------
// FUTURE IMPROVEMENTS
// ---------------------------------------------------------------------------
// 1. Decide on a consistent navigation pattern:
//    - Either pass the full OrderEntity via constructor (MaterialPageRoute),
//    - Or pass only the order ID via route arguments and fetch from repository.
// 2. Implement a proper loading/error state if using ID-based fetching.
// 3. Add a refresh mechanism (e.g., PullToRefresh) to reload order data.
// 4. Consider using a ViewModel / Provider for state management.
// ---------------------------------------------------------------------------
