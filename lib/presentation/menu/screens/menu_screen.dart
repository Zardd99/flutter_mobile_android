import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_card.dart';

/// Screen that displays the menu items and provides management actions.
///
/// Uses a [MenuCoordinator] for navigation and confirmation dialogs,
/// and a [MenuViewModel] (provided via Provider) for state and business logic.
/// Implements efficient scrolling with list caching and state preservation.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

/// State class for [MenuScreen].
///
/// Manages the lifecycle, coordinates with the coordinator and view model,
/// and builds the UI based on the current view model state.
class _MenuScreenState extends State<MenuScreen> {
  // ---------------------------------------------------------------------------
  // Dependencies and controllers
  // ---------------------------------------------------------------------------

  late MenuCoordinator _coordinator;
  late MenuViewModel _viewModel;

  /// Controller for fine-grained scroll control and resource cleanup.
  final ScrollController _scrollController = ScrollController();

  // ---------------------------------------------------------------------------
  // Lifecycle methods
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Defer data loading until after the first frame to avoid
    // building with incomplete state or causing layout jank.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize coordinator and view model as soon as context is available.
    // This ensures navigation and Provider access are ready.
    _coordinator = MenuCoordinator(context);
    _viewModel = Provider.of<MenuViewModel>(context);
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // View‑model change listener
  // ---------------------------------------------------------------------------

  /// Triggers a rebuild whenever the view model notifies listeners.
  void _onViewModelChanged() {
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Data operations
  // ---------------------------------------------------------------------------

  /// Loads the initial set of menu items.
  Future<void> _loadData() async {
    await _viewModel.loadMenuItems();
  }

  /// Handles the delete flow: confirmation dialog via coordinator,
  /// then calls the view model to perform deletion.
  Future<void> _handleDeleteItem(String id, String name) async {
    final confirmed = await _coordinator.confirmDelete(name);

    if (!confirmed) {
      return;
    }

    await _viewModel.deleteMenuItem(id);
  }

  // ---------------------------------------------------------------------------
  // UI building
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _coordinator.navigateBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _viewModel.refreshMenuItems,
            tooltip: 'Refresh menu',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _coordinator.navigateToAddMenuItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the main content area based on the current view model state.
  Widget _buildBody() {
    // Show a full-screen loader only during the initial load when no items exist.
    if (_viewModel.isLoading && _viewModel.menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Display error state with retry option.
    if (_viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${_viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    // Efficient list of menu items with caching and state preservation.
    return ListView.builder(
      controller: _scrollController,
      itemCount: _viewModel.menuItems.length,
      // Preserve state of items when they are scrolled off-screen.
      addAutomaticKeepAlives: true,
      // Prevent repainting of off-screen items.
      addRepaintBoundaries: true,
      // Load items slightly outside the viewport for smoother scrolling.
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final item = _viewModel.menuItems[index];
        return MenuItemCard(
          // Unique key improves diffing and performance.
          key: ValueKey(item.id),
          menuItem: item,
          onTap: () => _coordinator.navigateToEditMenuItem(item.id),
          onToggleAvailability: () =>
              _viewModel.toggleMenuItemAvailability(item),
          onDelete: () => _handleDeleteItem(item.id, item.name),
          showActions: true,
        );
      },
    );
  }
}
