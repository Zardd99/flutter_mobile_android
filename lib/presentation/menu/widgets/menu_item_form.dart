import 'package:flutter/material.dart';

class MenuItemForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final String submitButtonText;

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

class MenuItemFormState extends State<MenuItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _preparationTimeController;

  final List<String> _selectedDietaryTags = [];
  bool _chefSpecial = false;
  bool _availability = true;

  final List<String> _availableDietaryTags = [
    'vegetarian',
    'vegan',
    'gluten-free',
    'dairy-free',
    'spicy',
    'nut-free',
  ];

  @override
  void initState() {
    super.initState();

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

    _selectedDietaryTags.addAll(
      List<String>.from(widget.initialData?['dietaryTags'] ?? []),
    );
    _chefSpecial = widget.initialData?['chefSpecial'] ?? false;
    _availability = widget.initialData?['availability'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
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

          // Description field
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

          // Price field
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

          // Category field
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

          // Preparation time field
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

          // Dietary tags
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

          // Checkboxes
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

          // Submit button
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
