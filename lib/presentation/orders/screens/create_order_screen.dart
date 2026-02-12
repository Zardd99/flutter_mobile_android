// 📁 create_order_screen.dart
///
/// This file defines the [CreateOrderScreen] widget, which provides a developer-friendly
/// interface for manually creating orders by submitting raw JSON payloads.
/// It is primarily intended for testing, debugging, or administrative workflows.
/// The screen integrates with [OrderManager] and requires a valid authentication token.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';

/// A stateful widget that renders a screen for creating orders via raw JSON input.
///
/// This screen is designed for technical users and internal testing. It provides
/// a full-screen [TextField] where a JSON order object can be entered manually.
/// On submission, the payload is sent to [OrderManager.createOrder] using the
/// current user's authentication token. Success or error feedback is displayed
/// via [SnackBar] or inline text.
///
/// The widget automatically navigates back after a successful creation, with
/// an optional action to view the order in the KDS (Kitchen Display System).
class CreateOrderScreen extends StatefulWidget {
  /// Creates a [CreateOrderScreen].
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

/// The state class for [CreateOrderScreen].
///
/// Manages the JSON input controller, the loading state, the response/error
/// message, and the order creation logic. It retrieves the [OrderManager]
/// from the dependency injector and the authentication token from [AuthManager].
class _CreateOrderScreenState extends State<CreateOrderScreen> {
  // ---------------------------------------------------------------------------
  // Private Fields
  // ---------------------------------------------------------------------------

  /// The business logic layer for order operations.
  late final OrderManager _orderManager;

  /// The authentication token of the currently logged-in user.
  /// Used to authorize the order creation request.
  late final String _authToken;

  /// Controller for the JSON input text field.
  ///
  /// Pre-filled with a minimal valid order skeleton to assist the user.
  final TextEditingController _jsonController = TextEditingController(
    text: jsonEncode({
      "orderType": "dine-in",
      "items": [
        {"menuItem": "", "quantity": 1, "price": 0},
      ],
      "customer": null,
    }),
  );

  /// Indicates whether an order creation request is currently in progress.
  bool _loading = false;

  /// The last error or response message to display inline, or `null` if none.
  String? _response;

  // ---------------------------------------------------------------------------
  // Lifecycle Methods
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Resolve dependencies.
    _orderManager = get<OrderManager>();

    // Obtain the authentication token from the AuthManager.
    // The token is guaranteed to be non-null because the user is already
    // authenticated before reaching this screen.
    _authToken = context.read<AuthManager>().token!;
  }

  @override
  void dispose() {
    // Release the text controller to prevent memory leaks.
    _jsonController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private Methods – Order Creation Logic
  // ---------------------------------------------------------------------------

  /// Handles the order creation process.
  ///
  /// Reads the JSON payload from [_jsonController], attempts to decode it,
  /// and delegates to [_orderManager.createOrder]. Updates the UI state
  /// ([_loading], [_response]) accordingly.
  ///
  /// On success:
  /// - Shows a [SnackBar] with an action to navigate to the KDS screen.
  /// - Closes the current screen via [Navigator.pop].
  ///
  /// On failure (either JSON parsing or business logic):
  /// - Displays the error message inline via [_response].
  Future<void> _createOrder() async {
    setState(() => _loading = true);

    try {
      // Parse the JSON string into a Map.
      final orderData = jsonDecode(_jsonController.text);

      // Perform the order creation request.
      final result = await _orderManager.createOrder(
        orderData: orderData,
        token: _authToken,
      );

      result.fold(
        onSuccess: (order) {
          // Success: notify user and provide navigation to KDS.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order created successfully!'),
              action: SnackBarAction(
                label: 'View in KDS',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.kds);
                },
              ),
            ),
          );

          // Close the creation screen.
          Navigator.pop(context);
        },
        onFailure: (failure) {
          // Business logic failure (e.g., validation error).
          setState(() => _response = 'Error: ${failure.message}');
        },
      );
    } catch (e) {
      // JSON decoding or other unexpected error.
      setState(() => _response = 'Error: $e');
    } finally {
      // Ensure loading indicator is hidden.
      setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build Method
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ------------------------------
            // JSON Input Field (Expands to fill available space)
            // ------------------------------
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null, // Allows unlimited lines
                expands: true, // Fills the parent height
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Order JSON',
                ),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------
            // Submit Button
            // ------------------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createOrder,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Order'),
                  ),
                ),
              ],
            ),

            // ------------------------------
            // Inline Error / Response Message
            // ------------------------------
            if (_response != null) ...[
              const SizedBox(height: 12),
              Text(_response!),
            ],
          ],
        ),
      ),
    );
  }
}
