import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_form.dart';

/// Screen responsible for adding a new menu item.
///
/// This stateful widget presents a form ([MenuItemForm]) where the user can
/// input all necessary details for a new menu item. Upon submission, it
/// communicates with the [MenuViewModel] to create the item via the backend,
/// provides user feedback via [MenuCoordinator], and navigates back upon
/// success.
///
/// The screen manages its own local loading state ([_isSubmitting]) to disable
/// interactions during the async operation and to show a progress indicator.
class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  /// Coordinates navigation and user feedback dialogs/snackbars.
  late final MenuCoordinator _coordinator;

  /// View model that handles the business logic for menu item operations.
  late final MenuViewModel _viewModel;

  // ---------------------------------------------------------------------------
  // Form State
  // ---------------------------------------------------------------------------

  /// Global key used to access the state of the [MenuItemForm] widget.
  /// This allows retrieval of the form data and validation state.
  final _formKey = GlobalKey<MenuItemFormState>();

  /// Indicates whether a submission is currently in progress.
  /// When `true`, the form and back button are disabled, and a progress
  /// indicator is shown in the app bar.
  bool _isSubmitting = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialise dependencies that require a BuildContext.
    // These cannot be initialised in initState because they depend on
    // InheritedWidgets (Provider) and the context not being fully available.
    _coordinator = MenuCoordinator(context);
    _viewModel = Provider.of<MenuViewModel>(context, listen: false);
  }

  // ---------------------------------------------------------------------------
  // Form Submission
  // ---------------------------------------------------------------------------

  /// Validates the form, collects the data, and delegates the creation
  /// operation to the [MenuViewModel].
  ///
  /// While the operation is in progress, the UI is locked ([_isSubmitting] =
  /// `true`). On success, a success snackbar is shown and the screen is popped.
  /// On failure, an error snackbar is shown with the failure message.
  /// Any unexpected exception is also caught and displayed.
  Future<void> _submitForm() async {
    // 1. Validate the form.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Lock the UI.
    setState(() {
      _isSubmitting = true;
    });

    try {
      // 3. Retrieve the form data from the child widget.
      final formData = _formKey.currentState!.getFormData();

      // 4. Invoke the view model to create the menu item.
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

      // 5. Handle the result using fold (success/failure pattern).
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
      // Catch any unexpected errors (e.g., network issues, JSON parsing).
      _coordinator.showErrorSnackBar('Failed to create menu item: $e');
    } finally {
      // 6. Unlock the UI.
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
        // Custom back button to respect the submission lock state.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => _coordinator.navigateBack(),
        ),
        actions: [
          // Show a progress indicator in the app bar while submitting.
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
