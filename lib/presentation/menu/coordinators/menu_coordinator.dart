import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';

class MenuCoordinator {
  final BuildContext context;

  MenuCoordinator(this.context);

  void navigateToMenuItemDetails(String menuItemId) {
    Navigator.pushNamed(
      context,
      AppRoutes.menuItemDetails,
      arguments: menuItemId,
    );
  }

  void navigateToAddMenuItem() {
    Navigator.pushNamed(context, AppRoutes.addMenuItem);
  }

  void navigateToEditMenuItem(String menuItemId) {
    Navigator.pushNamed(context, AppRoutes.editMenuItem, arguments: menuItemId);
  }

  void navigateToCategories() {
    Navigator.pushNamed(context, AppRoutes.menuCategories);
  }

  void navigateBack() {
    Navigator.of(context).pop();
  }

  void showFilterDialog(
    Function({
      String? category,
      String? search,
      bool? available,
      bool? chefSpecial,
    })
    applyFilters,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FilterBottomSheet(onApplyFilters: applyFilters);
      },
    );
  }

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
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<String?> showCategoryPicker({
    required List<String> categories,
    String? selectedCategory,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return CategoryPickerBottomSheet(
          categories: categories,
          selectedCategory: selectedCategory,
        );
      },
    );
  }

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

    return confirmed ?? false;
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function({
    String? category,
    String? search,
    bool? available,
    bool? chefSpecial,
  })
  onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _searchQuery = '';
  bool _availableOnly = false;
  bool _chefSpecialOnly = false;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filter Menu Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Search field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search by name or description',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _searchQuery = value,
          ),
          const SizedBox(height: 16),

          // Category filter
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Categories')),
              DropdownMenuItem(value: 'pasta', child: Text('Pasta')),
              DropdownMenuItem(value: 'seafood', child: Text('Seafood')),
              DropdownMenuItem(value: 'salad', child: Text('Salad')),
              DropdownMenuItem(value: 'dessert', child: Text('Dessert')),
              DropdownMenuItem(value: 'appetizer', child: Text('Appetizer')),
              DropdownMenuItem(value: 'main', child: Text('Main Course')),
              DropdownMenuItem(value: 'dessert', child: Text('Dessert')),
              DropdownMenuItem(value: 'beverage', child: Text('Beverage')),
            ],
            initialValue: _selectedCategory,
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 16),

          // Availability filter
          CheckboxListTile(
            title: const Text('Show only available items'),
            value: _availableOnly,
            onChanged: (value) =>
                setState(() => _availableOnly = value ?? false),
          ),

          // Chef special filter
          CheckboxListTile(
            title: const Text('Show only chef specials'),
            value: _chefSpecialOnly,
            onChanged: (value) =>
                setState(() => _chefSpecialOnly = value ?? false),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      category: _selectedCategory,
                      search: _searchQuery.isNotEmpty ? _searchQuery : null,
                      available: _availableOnly,
                      chefSpecial: _chefSpecialOnly,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CategoryPickerBottomSheet extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;

  const CategoryPickerBottomSheet({
    super.key,
    required this.categories,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select Category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category),
                trailing: category == selectedCategory
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => Navigator.of(context).pop(category),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
