// 📁 menu_item_form.dart
///
/// This file provides a reusable form widget for creating and editing menu items.
/// It includes all necessary input fields, validation, and state management
/// for the menu item creation/edition flow. The form is designed to be used
/// within a modal bottom sheet or a dedicated screen.

import 'package:flutter/material.dart';

/// A stateful widget that renders a complete form for menu item data.
///
/// This form is used both for creating new menu items and editing existing ones.
/// It manages its own internal state (controllers, selected tags, toggles) and
/// exposes methods to validate and retrieve the form data. The form is fully
/// controlled by the parent widget via [initialData], [onSubmit], [isSubmitting],
/// and [submitButtonText].
///
/// The form includes:
/// - Text fields for name, description, price, category ID, preparation time
/// - A filter chip selector for dietary tags
/// - Checkboxes for "Chef's Special" and "Availability"
/// - A submit button that shows a loading indicator during submission
class MenuItemForm extends StatefulWidget {
  /// Optional initial data to populate the form in edit mode.
  ///
  /// The map can contain any subset of the following keys:
  /// - 'name' (String)
  /// - 'description' (String)
  /// - 'price' (double)
  /// - 'categoryId' (String)
  /// - 'preparationTime' (int)
  /// - 'dietaryTags' (List<String>)
  /// - 'chefSpecial' (bool)
  /// - 'availability' (bool)
  final Map<String, dynamic>? initialData;

  /// Callback invoked when the form passes validation and the submit button is pressed.
  ///
  /// The parent widget is expected to handle the actual submission logic
  /// (e.g., calling a ViewModel method) and control the [isSubmitting] flag.
  final VoidCallback onSubmit;

  /// Whether a submission is currently in progress.
  ///
  /// When `true`, the submit button is disabled and shows a loading spinner.
  final bool isSubmitting;

  /// The text displayed on the submit button (e.g., 'Create', 'Update').
  final String submitButtonText;

  /// Creates a [MenuItemForm].
  const MenuItemForm({
    super.key,
    this.initialData,
    required this.onSubmit,
    required this.isSubmitting,
    required this.submitButtonText,
  });

  @override
  State<MenuItemForm> createState() => MenuItemFormState();
}

/// The state class for [MenuItemForm].
///
/// Manages all text editing controllers, form validation state, dietary tag
/// selection, and boolean toggles. Provides public methods [validate] and
/// [getFormData] for the parent widget to trigger validation and retrieve
/// the collected data.
///
/// This state class is intentionally public to allow external access to its
/// methods (e.g., from a parent widget that holds a GlobalKey<MenuItemFormState>).
class MenuItemFormState extends State<MenuItemForm> {
  // ---------------------------------------------------------------------------
  // Form State Keys & Controllers
  // ---------------------------------------------------------------------------

  /// Global key used to validate the entire form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the menu item name input field.
  late TextEditingController _nameController;

  /// Controller for the description input field.
  late TextEditingController _descriptionController;

  /// Controller for the price input field.
  late TextEditingController _priceController;

  /// Controller for the category ID input field.
  late TextEditingController _categoryController;

  /// Controller for the preparation time input field.
  late TextEditingController _preparationTimeController;

  // ---------------------------------------------------------------------------
  // Form Values (Non‑Text Fields)
  // ---------------------------------------------------------------------------

  /// Currently selected dietary tags.
  final List<String> _selectedDietaryTags = [];

  /// Whether the item is marked as a chef's special.
  bool _chefSpecial = false;

  /// Whether the item is currently available.
  bool _availability = true;

  /// List of all available dietary tags that can be selected.
  final List<String> _availableDietaryTags = [
    'vegetarian',
    'vegan',
    'gluten-free',
    'dairy-free',
    'spicy',
    'nut-free',
  ];

  // ---------------------------------------------------------------------------
  // Lifecycle Methods
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Initialize text controllers with initial data (or empty defaults).
    _nameController = TextEditingController(
      text: widget.initialData?['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialData?['description'] ?? '',
    );
    _priceController = TextEditingController(
      text: widget.initialData?['price']?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialData?['categoryId'] ?? '',
    );
    _preparationTimeController = TextEditingController(
      text: widget.initialData?['preparationTime']?.toString() ?? '15',
    );

    // Populate dietary tags if provided.
    _selectedDietaryTags.addAll(
      List<String>.from(widget.initialData?['dietaryTags'] ?? []),
    );

    // Set boolean flags from initial data, falling back to defaults.
    _chefSpecial = widget.initialData?['chefSpecial'] ?? false;
    _availability = widget.initialData?['availability'] ?? true;
  }

  @override
  void dispose() {
    // Dispose all controllers to free resources.
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Public Methods (For Parent Widget)
  // ---------------------------------------------------------------------------

  /// Validates the form and returns `true` if all fields are valid.
  ///
  /// Should be called by the parent widget before retrieving form data.
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  /// Returns a map containing all current form field values.
  ///
  /// The returned map has the same structure as the [initialData] map and
  /// is suitable for passing to [MenuViewModel.createMenuItem] or
  /// [MenuViewModel.updateMenuItem].
  Map<String, dynamic> getFormData() {
    return {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'categoryId': _categoryController.text,
      'dietaryTags': List<String>.from(_selectedDietaryTags),
      'preparationTime': int.tryParse(_preparationTimeController.text) ?? 15,
      'chefSpecial': _chefSpecial,
      'availability': _availability,
    };
  }

  // ---------------------------------------------------------------------------
  // Build Method
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ------------------------------
          // Item Name
          // ------------------------------
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter item name';
              }
              if (value.length > 100) {
                return 'Name cannot exceed 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ------------------------------
          // Description
          // ------------------------------
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              if (value.length > 500) {
                return 'Description cannot exceed 500 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ------------------------------
          // Price
          // ------------------------------
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Price *',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final price = double.tryParse(value ?? '');
              if (price == null || price <= 0) {
                return 'Please enter a valid price greater than 0';
              }
              if (price > 1000) {
                return 'Price cannot exceed \$1000';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ------------------------------
          // Category ID
          // ------------------------------
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category ID *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter category ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ------------------------------
          // Preparation Time
          // ------------------------------
          TextFormField(
            controller: _preparationTimeController,
            decoration: const InputDecoration(
              labelText: 'Preparation Time (minutes) *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final time = int.tryParse(value ?? '');
              if (time == null || time <= 0) {
                return 'Please enter a valid preparation time';
              }
              if (time > 360) {
                return 'Preparation time cannot exceed 6 hours';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ------------------------------
          // Dietary Tags (Filter Chips)
          // ------------------------------
          const Text(
            'Dietary Tags',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _availableDietaryTags.map((tag) {
              final isSelected = _selectedDietaryTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDietaryTags.add(tag);
                    } else {
                      _selectedDietaryTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ------------------------------
          // Chef's Special & Availability
          // ------------------------------
          Row(
            children: [
              Checkbox(
                value: _chefSpecial,
                onChanged: (value) {
                  setState(() {
                    _chefSpecial = value ?? false;
                  });
                },
              ),
              const Text("Chef's Special"),
              const SizedBox(width: 32),
              Checkbox(
                value: _availability,
                onChanged: (value) {
                  setState(() {
                    _availability = value ?? true;
                  });
                },
              ),
              const Text('Available'),
            ],
          ),
          const SizedBox(height: 24),

          // ------------------------------
          // Submit Button
          // ------------------------------
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : widget.onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.isSubmitting
                ? const CircularProgressIndicator()
                : Text(widget.submitButtonText),
          ),
        ],
      ),
    );
  }
}
