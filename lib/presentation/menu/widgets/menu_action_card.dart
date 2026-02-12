// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/menu/widgets/menu_action_card.dart
// Description: A reusable action card widget for the menu management section.
//              Displays an icon and a title, and responds to tap gestures.
//              Used for quick actions like "Add Item", "Edit Categories",
//              "Import Menu", etc.
// *****************************************************************************

import 'package:flutter/material.dart';

/// A compact, tappable card that represents a single menu action.
///
/// This widget is designed to be used in a grid or row of action buttons.
/// It provides a consistent visual style with a centred icon and a text label.
/// The card has a fixed size (100x100) to maintain alignment in a grid layout.
///
/// Typical usage:
/// ```dart
/// MenuActionCard(
///   icon: Icons.add,
///   title: 'Add Item',
///   onTap: () => _navigateToAddItemScreen(),
/// )
/// ```
class MenuActionCard extends StatelessWidget {
  /// The icon displayed at the top of the card.
  final IconData icon;

  /// The short descriptive text displayed below the icon.
  ///
  /// The text is automatically truncated with an ellipsis if it exceeds two lines.
  final String title;

  /// Callback invoked when the card is tapped.
  final VoidCallback onTap;

  const MenuActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ----- Icon (accent colour: green) -----
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(height: 8),

              // ----- Title (bold, max 2 lines) -----
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
