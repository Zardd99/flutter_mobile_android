import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';

/// Coordinates navigation and user feedback for the menu management feature.
///
/// This class is responsible for all screen transitions, dialog presentations,
/// and snackbar notifications related to menu items. It encapsulates the
/// navigation logic and decouples the UI components from the routing details.
///
/// By using a coordinator, we centralise navigation calls, making them easier
/// to maintain, test, and modify (e.g., switching from pushNamed to a custom
/// transition) without touching every widget.
class MenuCoordinator {
  /// The build context used to access the navigator and scaffold messenger.
  ///
  /// This context should be obtained from a widget that is already part of the
  /// widget tree and has access to a [Navigator] (typically a `BuildContext`
  /// from a `State` or a builder function).
  final BuildContext context;

  /// Creates a new [MenuCoordinator] with the given [context].
  const MenuCoordinator(this.context);

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Navigates to the "Add Menu Item" screen.
  ///
  /// Uses [Navigator.pushNamed] with the route defined in [AppRoutes.addMenuItem].
  void navigateToAddMenuItem() {
    Navigator.pushNamed(context, AppRoutes.addMenuItem);
  }

  /// Navigates to the "Edit Menu Item" screen for a specific item.
  ///
  /// The [menuItemId] is passed as a route argument and will be available to
  /// the target screen via [ModalRoute.of(context)!.settings.arguments].
  void navigateToEditMenuItem(String menuItemId) {
    Navigator.pushNamed(context, AppRoutes.editMenuItem, arguments: menuItemId);
  }

  /// Pops the current screen off the navigation stack.
  ///
  /// Equivalent to pressing the system back button or calling `Navigator.pop()`.
  void navigateBack() {
    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------------
  // Dialog Helpers
  // ---------------------------------------------------------------------------

  /// Displays a generic confirmation dialog with customisable text and actions.
  ///
  /// - [title]: The dialog title.
  /// - [message]: The body text of the dialog.
  /// - [onConfirm]: Callback executed when the user presses the confirm button.
  /// - [confirmText]: Label for the confirm button (default: 'Confirm').
  /// - [cancelText]: Label for the cancel button (default: 'Cancel').
  void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog.
              onConfirm(); // Execute the confirmation action.
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Asks the user to confirm deletion of an item.
  ///
  /// Displays a specialised delete confirmation dialog with a red "Delete"
  /// button. Returns a [Future<bool>] that completes with `true` if the user
  /// confirmed, otherwise `false`.
  ///
  /// - [itemName]: The name of the item to be deleted, shown in the dialog.
  Future<bool> confirmDelete(String itemName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If the dialog was dismissed (e.g., by tapping outside), treat as cancel.
    return confirmed ?? false;
  }

  // ---------------------------------------------------------------------------
  // Snackbar Notifications
  // ---------------------------------------------------------------------------

  /// Shows a brief informational message at the bottom of the screen.
  ///
  /// The snackbar is displayed for 2 seconds with default styling.
  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Shows a success snackbar with a green background.
  ///
  /// Typically used to confirm successful operations (e.g., "Item updated").
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an error snackbar with a red background and longer duration.
  ///
  /// - [message]: The error description to display.
  /// - Duration: 3 seconds (longer than info/success to ensure readability).
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
