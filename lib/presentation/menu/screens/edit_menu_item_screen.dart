import 'package:flutter/material.dart';

class EditMenuItemScreen extends StatelessWidget {
  final String menuItemId;

  const EditMenuItemScreen({super.key, required this.menuItemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Editing Item ID: $menuItemId',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit screen coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
