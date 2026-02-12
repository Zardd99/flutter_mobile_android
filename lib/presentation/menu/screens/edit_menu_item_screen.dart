// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/menu/screens/edit_menu_item_screen.dart
// Description: Screen for editing an existing menu item.
//              Loads the current item data, displays a form for modifications,
//              and handles update/delete operations with user confirmation.
//              Uses MenuCoordinator for navigation and feedback,
//              and MenuViewModel for business logic.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_form.dart';

/// Screen that allows editing an existing menu item.
///
/// This screen is stateful because it performs asynchronous operations
/// (loading the item, submitting updates, deleting). It expects a
/// [menuItemId] parameter to identify which item to edit.
///
/// The screen:
///   1. Fetches the current menu item data via [MenuViewModel].
///   2. Displays a [MenuItemForm] pre‑filled with the existing values.
///   3. On save, computes the delta of changed fields and sends only those
///      to the [MenuViewModel.updateMenuItem] method.
///   4. On delete, asks for confirmation via the coordinator, then deletes.
///   5. Provides visual feedback via snackbars and disables interactions
///      while operations are in progress.
class EditMenuItemScreen extends StatefulWidget {
  /// The unique identifier of the menu item to edit.
  final String menuItemId;

  const EditMenuItemScreen({super.key, required this.menuItemId});

  @override
  State<EditMenuItemScreen> createState() => _EditMenuItemScreenState();
}

/// State object for [EditMenuItemScreen].
///
/// Manages the loading state, error state, form submission, and deletion.
/// Uses a [GlobalKey] of type [MenuItemFormState] to access the form's
/// current data and validation state.
class _EditMenuItemScreenState extends State<EditMenuItemScreen> {
  // -------------------------------------------------------------------------
  // DEPENDENCIES (lazy‑loaded)
  // -------------------------------------------------------------------------

  /// Handles navigation and user feedback (snackbars, dialogs).
  late MenuCoordinator _coordinator;

  /// Provides access to menu item operations.
  late MenuViewModel _viewModel;

  // -------------------------------------------------------------------------
  // STATE FIELDS
  // -------------------------------------------------------------------------

  /// Global key to interact with the [MenuItemForm] widget.
  /// Used to retrieve form data and trigger validation.
  final _formKey = GlobalKey<MenuItemFormState>();

  /// Indicates whether the initial menu item data is being loaded.
  bool _isLoading = true;

  /// Indicates whether a save or delete operation is in progress.
  bool _isSubmitting = false;

  /// The loaded menu item, once available.
  MenuItem? _menuItem;

  /// Error message if loading fails; null otherwise.
  String? _error;

  // -------------------------------------------------------------------------
  // LIFECYCLE METHODS
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Defer data loading until after the first frame to ensure
    // the BuildContext is valid and the ViewModel is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<MenuViewModel>(context, listen: false);
      _loadMenuItem();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Coordinator depends on BuildContext; instantiate it here.
    _coordinator = MenuCoordinator(context);
  }

  // -------------------------------------------------------------------------
  // PRIVATE METHODS – DATA LOADING
  // -------------------------------------------------------------------------

  /// Fetches the menu item by its ID from the ViewModel.
  ///
  /// Sets [_isLoading] to false when complete, and updates [_menuItem]
  /// on success or [_error] on failure. Handles exceptions gracefully.
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

  // -------------------------------------------------------------------------
  // PRIVATE METHODS – FORM SUBMISSION
  // -------------------------------------------------------------------------

  /// Collects changed fields from the form and sends an update request.
  ///
  /// Steps:
  ///   1. Validate the form. If invalid, abort.
  ///   2. Compare current [_menuItem] with the new form data.
  ///   3. If no changes were made, show an info snackbar and return.
  ///   4. Otherwise, call [MenuViewModel.updateMenuItem] with the delta.
  ///   5. On success, show success snackbar and navigate back.
  ///   6. On failure, show error snackbar and remain on screen.
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

      // Build a delta of only the fields that have changed.
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

  // -------------------------------------------------------------------------
  // PRIVATE METHODS – DELETION
  // -------------------------------------------------------------------------

  /// Asks for confirmation, then deletes the current menu item.
  ///
  /// Uses the coordinator to display a confirmation dialog.
  /// If confirmed, calls [MenuViewModel.deleteMenuItem].
  /// On success, navigates back; on failure, shows an error.
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

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------------
    // LOADING STATE
    // -----------------------------------------------------------------------
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Menu Item')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // -----------------------------------------------------------------------
    // ERROR STATE
    // -----------------------------------------------------------------------
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

    // -----------------------------------------------------------------------
    // NORMAL STATE – DISPLAY FORM
    // -----------------------------------------------------------------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => _coordinator.navigateBack(),
        ),
        actions: [
          // Delete button (disabled while submitting)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isSubmitting ? null : _deleteItem,
            tooltip: 'Delete item',
          ),
          // Show a progress indicator when submitting.
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
          // Pre‑fill the form with the existing menu item data.
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
