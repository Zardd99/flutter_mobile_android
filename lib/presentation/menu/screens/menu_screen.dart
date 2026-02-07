import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_card.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_action_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late MenuCoordinator _coordinator;
  late MenuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _coordinator = MenuCoordinator(context);
    _viewModel = get<MenuViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _loadData();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  Future<void> _loadData() async {
    await _viewModel.loadMenuItems();
  }

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
          if (_viewModel.searchQuery != null ||
              _viewModel.availableOnly ||
              _viewModel.chefSpecialOnly)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _viewModel.clearFilters,
              tooltip: 'Clear filters',
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () =>
                _coordinator.showFilterDialog(_viewModel.applyFilters),
            tooltip: 'Filter menu items',
          ),
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

  Widget _buildBody() {
    if (_viewModel.isLoading && _viewModel.menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return CustomScrollView(
      slivers: [
        // Header section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.restaurant_menu,
                      value: _viewModel.totalItems.toString(),
                      label: 'Total Items',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      value: _viewModel.availableItems.toString(),
                      label: 'Available',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.star,
                      value: _viewModel.chefSpecials.toString(),
                      label: 'Chef Specials',
                      color: Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action cards
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    MenuActionCard(
                      icon: Icons.view_list,
                      title: 'View Menu',
                      onTap: () => _coordinator.navigateToMenuItemDetails(''),
                    ),
                    MenuActionCard(
                      icon: Icons.add_circle,
                      title: 'Add Item',
                      onTap: _coordinator.navigateToAddMenuItem,
                    ),
                    MenuActionCard(
                      icon: Icons.edit,
                      title: 'Edit Menu',
                      onTap: () => _coordinator.navigateToEditMenuItem(''),
                    ),
                    MenuActionCard(
                      icon: Icons.category,
                      title: 'Categories',
                      onTap: _coordinator.navigateToCategories,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Menu items header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu Items (${_viewModel.filteredMenuItems.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_viewModel.searchQuery != null)
                      Chip(
                        label: Text('Search: ${_viewModel.searchQuery}'),
                        onDeleted: () => _viewModel.applyFilters(search: null),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Menu items list
        if (_viewModel.filteredMenuItems.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No menu items found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  if (_viewModel.searchQuery != null ||
                      _viewModel.availableOnly ||
                      _viewModel.chefSpecialOnly)
                    TextButton(
                      onPressed: _viewModel.clearFilters,
                      child: const Text('Clear filters'),
                    ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _viewModel.filteredMenuItems[index];
              return MenuItemCard(
                menuItem: item,
                onTap: () => _coordinator.navigateToMenuItemDetails(item.id),
                onToggleAvailability: () =>
                    _viewModel.toggleMenuItemAvailability(item),
                showActions: true,
              );
            }, childCount: _viewModel.filteredMenuItems.length),
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
