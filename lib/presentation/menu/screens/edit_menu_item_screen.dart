import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_form.dart';

class EditMenuItemScreen extends StatefulWidget {
  final String menuItemId;

  const EditMenuItemScreen({super.key, required this.menuItemId});

  @override
  State<EditMenuItemScreen> createState() => _EditMenuItemScreenState();
}

class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  late MenuCoordinator _coordinator;
  late MenuViewModel _viewModel;
  final _formKey = GlobalKey<MenuItemFormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;
  MenuItem? _menuItem;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<MenuViewModel>(context, listen: false);
      _loadMenuItem();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = MenuCoordinator(context);
  }

  Future<void> _loadMenuItem() async {
    try {
      final result = await _viewModel.getMenuItemById(widget.menuItemId);

      result.fold(
        onSuccess: (menuItem) {
          if (mounted) {
            setState(() {
              _menuItem = menuItem;
              _isLoading = false;
            });
          }
        },
        onFailure: (failure) {
          if (mounted) {
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load menu item: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

    try {
      final formData = _formKey.currentState!.getFormData();
      final updates = <String, dynamic>{};

      if (_menuItem!.name != formData['name']) {
        updates['name'] = formData['name'];
      }
      if (_menuItem!.description != formData['description']) {
        updates['description'] = formData['description'];
      }
      if (_menuItem!.price != formData['price']) {
        updates['price'] = formData['price'];
      }
      if (_menuItem!.categoryId != formData['categoryId']) {
        updates['category'] = formData['categoryId'];
      }
      if (_menuItem!.dietaryTags.toString() !=
          (formData['dietaryTags'] as List<String>).toString()) {
        updates['dietaryTags'] = formData['dietaryTags'];
      }
      if (_menuItem!.preparationTime != formData['preparationTime']) {
        updates['preparationTime'] = formData['preparationTime'];
      }
      if (_menuItem!.chefSpecial != formData['chefSpecial']) {
        updates['chefSpecial'] = formData['chefSpecial'];
      }
      if (_menuItem!.availability != formData['availability']) {
        updates['availability'] = formData['availability'];
      }

      if (updates.isEmpty) {
        _coordinator.showInfoSnackBar('No changes to save');
        return;
      }

      final result = await _viewModel.updateMenuItem(
        widget.menuItemId,
        updates,
      );

      result.fold(
        onSuccess: (updatedItem) {
          _coordinator.showSuccessSnackBar('Menu item updated successfully');
          _coordinator.navigateBack();
        },
        onFailure: (failure) {
          _coordinator.showErrorSnackBar(failure.message);
        },
      );
    } catch (e) {
      _coordinator.showErrorSnackBar('Failed to update menu item: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await _coordinator.confirmDelete(_menuItem!.name);

    if (!confirmed) {
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

    try {
      final result = await _viewModel.deleteMenuItem(widget.menuItemId);

      result.fold(
        onSuccess: (_) {
          _coordinator.showSuccessSnackBar('Menu item deleted successfully');
          _coordinator.navigateBack();
        },
        onFailure: (failure) {
          _coordinator.showErrorSnackBar(failure.message);
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
        },
      );
    } catch (e) {
      _coordinator.showErrorSnackBar('Failed to delete menu item: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Menu Item')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Menu Item'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _coordinator.navigateBack(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMenuItem,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => _coordinator.navigateBack(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isSubmitting ? null : _deleteItem,
            tooltip: 'Delete item',
          ),
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MenuItemForm(
          key: _formKey,
          initialData: {
            'name': _menuItem!.name,
            'description': _menuItem!.description,
            'price': _menuItem!.price,
            'categoryId': _menuItem!.categoryId,
            'dietaryTags': _menuItem!.dietaryTags,
            'preparationTime': _menuItem!.preparationTime,
            'chefSpecial': _menuItem!.chefSpecial,
            'availability': _menuItem!.availability,
          },
          onSubmit: _submitForm,
          isSubmitting: _isSubmitting,
          submitButtonText: 'Update Item',
        ),
      ),
    );
  }
}
