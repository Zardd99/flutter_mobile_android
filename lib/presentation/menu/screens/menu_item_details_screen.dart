import 'package:flutter/material.dart';

/// A temporary screen that displays placeholder details for a specific menu item.
///
/// This screen is intended as a scaffold for the future menu item details view.
/// Currently, it shows a static UI with the menu item ID and a placeholder message.
/// The screen receives the [menuItemId] as a required parameter via the constructor.
///
/// Once the full details feature is implemented, this screen will be replaced
/// or extended to display actual item information, images, nutritional data,
/// and edit capabilities.
class MenuItemDetailsScreen extends StatelessWidget {
  /// The unique identifier of the menu item to display.
  ///
  /// This value is passed as an argument when navigating to this screen and is
  /// displayed in the body for verification purposes.
  final String menuItemId;

  /// Creates a new [MenuItemDetailsScreen] for the given [menuItemId].
  const MenuItemDetailsScreen({super.key, required this.menuItemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody());
  }

  /// Builds the app bar with a back button and a static title.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Menu Item Details'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        // Pops the current screen off the navigation stack.
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Builds the main content area of the screen.
  ///
  /// Displays a centered column containing a restaurant icon, the menu item ID,
  /// and a placeholder "coming soon" message.
  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large decorative icon.
          const Icon(Icons.restaurant_menu, size: 80, color: Colors.green),
          const SizedBox(height: 20),

          // Display the provided menu item ID.
          Text(
            'Menu Item ID: $menuItemId',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),

          // Placeholder text indicating incomplete implementation.
          const Text(
            'Details screen coming soon...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
