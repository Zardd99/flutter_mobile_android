// 📁 categories_screen.dart
///
/// This file defines the [CategoriesScreen] widget, which is responsible for
/// displaying the categories management placeholder UI.
/// Currently, it serves as a future feature placeholder with a static layout.
/// No business logic is implemented; only visual scaffolding.

import 'package:flutter/material.dart';

/// A stateless widget that represents the Categories screen.
///
/// This screen is a placeholder for future categories management functionality.
/// It displays a centered column with a category icon, title, and a "Coming soon"
/// subtitle. The app bar includes a back button for navigation.
///
/// The screen uses a [Scaffold] as its root structure and centers its content
/// both horizontally and vertically.
class CategoriesScreen extends StatelessWidget {
  /// Creates a [CategoriesScreen].
  ///
  /// The [key] parameter is forwarded to the superclass and is optional.
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ------------------------------
      // AppBar configuration
      // ------------------------------
      appBar: AppBar(
        // Screen title
        title: const Text('Categories'),

        // Back navigation button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ------------------------------
      // Body content
      // ------------------------------
      // The entire body is centered and arranged in a column.
      body: const Center(
        child: Column(
          // Vertical centering
          mainAxisAlignment: MainAxisAlignment.center,

          // Widgets are displayed in vertical order
          children: [
            // Primary visual element: large category icon
            Icon(Icons.category, size: 80, color: Colors.purple),

            // Spacing between icon and title
            SizedBox(height: 20),

            // Main heading
            Text(
              'Categories Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Spacing between title and subtitle
            SizedBox(height: 10),

            // Placeholder subtitle
            Text('Coming soon...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
