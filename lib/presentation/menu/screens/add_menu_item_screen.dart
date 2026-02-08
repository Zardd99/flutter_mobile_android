import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_form.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  late MenuCoordinator _coordinator;
  late MenuViewModel _viewModel;
  final _formKey = GlobalKey<MenuItemFormState>();
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = MenuCoordinator(context);
    _viewModel = Provider.of<MenuViewModel>(context, listen: false);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final formData = _formKey.currentState!.getFormData();

      final result = await _viewModel.createMenuItem(
        name: formData['name'] as String,
        description: formData['description'] as String,
        price: formData['price'] as double,
        categoryId: formData['categoryId'] as String,
        dietaryTags: List<String>.from(formData['dietaryTags']),
        preparationTime: formData['preparationTime'] as int,
        chefSpecial: formData['chefSpecial'] as bool,
        availability: formData['availability'] as bool,
      );

      result.fold(
        onSuccess: (menuItem) {
          _coordinator.showSuccessSnackBar('Menu item created successfully');
          _coordinator.navigateBack();
        },
        onFailure: (failure) {
          _coordinator.showErrorSnackBar(failure.message);
        },
      );
    } catch (e) {
      _coordinator.showErrorSnackBar('Failed to create menu item: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => _coordinator.navigateBack(),
        ),
        actions: [
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
          onSubmit: _submitForm,
          isSubmitting: _isSubmitting,
          submitButtonText: 'Create Item',
        ),
      ),
    );
  }
}
