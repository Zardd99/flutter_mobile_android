import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/menu/coordinators/menu_coordinator.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/menu/widgets/menu_item_card.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator = MenuCoordinator(context);
    _viewModel = Provider.of<MenuViewModel>(context);
    _viewModel.addListener(_onViewModelChanged);
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

  Future<void> _handleDeleteItem(String id, String name) async {
    final confirmed = await _coordinator.confirmDelete(name);

    if (!confirmed) {
      return;
    }

    await _viewModel.deleteMenuItem(id);
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

    return ListView.builder(
      itemCount: _viewModel.menuItems.length,
      itemBuilder: (context, index) {
        final item = _viewModel.menuItems[index];
        return MenuItemCard(
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
