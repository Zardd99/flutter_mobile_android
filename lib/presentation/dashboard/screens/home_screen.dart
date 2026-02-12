// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/home/screens/home_screen.dart
// Description: Main dashboard screen for authenticated users.
//              Displays welcome header, order statistics, quick actions,
//              and management module grid. Includes navigation drawer
//              and logout functionality.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';

/// The main dashboard screen of the application.
///
/// This screen is displayed after successful authentication. It provides:
///   - A personalised welcome header with user avatar.
///   - Real‑time order statistics (revenue, order count, average value).
///   - Quick action cards for common tasks (take order, kitchen display, add item).
///   - A grid of management modules (Menu, Orders, Inventory, etc.).
///   - A navigation drawer and logout confirmation dialog.
///
/// The screen is stateful because it fetches and displays live order statistics.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State object for [HomeScreen].
///
/// Manages the loading and display of order statistics. Uses [OrderManager]
/// from the dependency injection container to fetch stats, and [AuthManager]
/// via Provider to access the current user and authentication token.
class _HomeScreenState extends State<HomeScreen> {
  // -------------------------------------------------------------------------
  // PRIVATE FIELDS
  // -------------------------------------------------------------------------

  /// The most recently fetched order statistics.
  /// `null` if no stats have been loaded yet.
  OrderStatsEntity? _orderStats;

  /// Indicates whether order statistics are currently being fetched.
  bool _loadingStats = true;

  // -------------------------------------------------------------------------
  // LIFECYCLE METHODS
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Delay the stats loading until after the first frame is rendered.
    // This ensures that BuildContext is valid and dependencies are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  // -------------------------------------------------------------------------
  // DATA FETCHING
  // -------------------------------------------------------------------------

  /// Fetches the latest order statistics from the remote API.
  ///
  /// This method is called once when the screen is initialised.
  /// It retrieves the authentication token from [AuthManager],
  /// then asks [OrderManager] to fetch the statistics.
  /// On completion, updates the UI with the result (or leaves stats as null).
  Future<void> _loadStats() async {
    final authManager = context.read<AuthManager>();
    // No token -> user is not authenticated; cannot fetch stats.
    if (authManager.token == null) return;

    final orderManager = get<OrderManager>();
    setState(() => _loadingStats = true);
    final result = await orderManager.getOrderStats(token: authManager.token!);
    setState(() {
      _orderStats = result.valueOrNull;
      _loadingStats = false;
    });
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authManager = context.read<AuthManager>();
    final user = authManager.currentUser;
    final userName = user?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _performLogout(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
        color: Colors.grey[50],
        child: CustomScrollView(
          slivers: [
            // Welcome header with user avatar and greeting.
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Order statistics cards (loading / error / data).
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStatsSection(),
              ),
            ),

            // Quick actions section header.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Quick action cards (Take Order, Kitchen Display, Add Menu Item).
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildQuickActions(),
              ),
            ),

            // Management modules section header.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'MANAGEMENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Responsive grid of management modules.
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: _buildModulesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // STATISTICS SECTION
  // -------------------------------------------------------------------------

  /// Builds the row of three statistic cards (revenue, orders, average value).
  ///
  /// Shows a loading spinner while [_loadingStats] is true.
  /// Displays actual data from [_orderStats] when available,
  /// or zero values if the fetch failed or returned null.
  Widget _buildStatsSection() {
    if (_loadingStats) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _orderStats;
    return Row(
      children: [
        _buildStatCard(
          label: 'Today\'s Revenue',
          value: stats != null
              ? '\$${stats.dailyEarnings.toStringAsFixed(2)}'
              : '\$0.00',
          icon: Icons.attach_money,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: 'Orders Today',
          value: '${stats?.todayOrderCount ?? 0}',
          icon: Icons.shopping_cart,
          color: Colors.blue.shade700,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: 'Avg. Order',
          value: stats != null
              ? '\$${stats.avgOrderValue.toStringAsFixed(2)}'
              : '\$0.00',
          icon: Icons.trending_up,
          color: Colors.purple.shade700,
        ),
      ],
    );
  }

  /// Builds a single statistic card with icon, value and label.
  ///
  /// [label] – description of the statistic.
  /// [value] – formatted value to display.
  /// [icon]  – icon representing the statistic.
  /// [color] – accent colour for the icon.
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // QUICK ACTIONS
  // -------------------------------------------------------------------------

  /// Builds a row of three quick action cards.
  ///
  /// Each card is a tappable area that navigates to a specific screen.
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_shopping_cart,
            label: 'Take Order',
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, AppRoutes.createOrder),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.kitchen,
            label: 'Kitchen Display',
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(context, AppRoutes.kds),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.restaurant_menu,
            label: 'Add Menu Item',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, AppRoutes.addMenuItem),
          ),
        ),
      ],
    );
  }

  /// Builds a single quick action card with icon, label and tap handler.
  ///
  /// [icon]   – icon displayed above the label.
  /// [label]  – short description.
  /// [color]  – accent colour for the icon.
  /// [onTap]  – callback executed when the card is tapped.
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MANAGEMENT MODULES GRID
  // -------------------------------------------------------------------------

  /// Builds a responsive grid of management module cards.
  ///
  /// The grid adapts to the screen width: 2 columns on mobile, 4 on larger devices.
  /// Each card navigates to the corresponding feature screen.
  Widget _buildModulesGrid() {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final crossAxisCount = isMobile ? 2 : 4;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      delegate: SliverChildListDelegate([
        _buildModuleCard(
          icon: Icons.restaurant_menu,
          label: 'Menu',
          route: AppRoutes.menu,
        ),
        _buildModuleCard(
          icon: Icons.shopping_cart,
          label: 'Orders',
          route: AppRoutes.orders,
        ),
        _buildModuleCard(
          icon: Icons.inventory,
          label: 'Inventory',
          route: AppRoutes.inventory,
        ),
        _buildModuleCard(
          icon: Icons.local_shipping,
          label: 'Suppliers',
          route: AppRoutes.suppliers,
        ),
        _buildModuleCard(
          icon: Icons.reviews,
          label: 'Reviews',
          route: AppRoutes.reviews,
        ),
        _buildModuleCard(
          icon: Icons.people,
          label: 'Users',
          route: AppRoutes.users,
        ),
        _buildModuleCard(
          icon: Icons.kitchen,
          label: 'KDS',
          route: AppRoutes.kds,
        ),
        _buildModuleCard(
          icon: Icons.settings,
          label: 'Settings',
          route: AppRoutes.settings,
        ),
      ]),
    );
  }

  /// Builds a single management module card.
  ///
  /// [icon]  – icon representing the module.
  /// [label] – name of the module.
  /// [route] – named route to navigate when tapped.
  Widget _buildModuleCard({
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.1),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // NAVIGATION DRAWER
  // -------------------------------------------------------------------------

  /// Builds the navigation drawer with user account header and menu items.
  ///
  /// The drawer displays the current user's name, email and avatar.
  /// Tapping a drawer item navigates to the corresponding screen
  /// and closes the drawer.
  Widget _buildDrawer(BuildContext context) {
    final authManager = context.read<AuthManager>();
    final user = authManager.currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Restaurant User'),
            accountEmail: Text(user?.email ?? 'user@restaurant.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name?.isNotEmpty ?? false)
                    ? user!.name![0].toUpperCase()
                    : 'R',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue.shade900),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: AppRoutes.home,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.restaurant_menu,
            label: 'Menu',
            route: AppRoutes.menu,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            label: 'Orders',
            route: AppRoutes.orders,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.kitchen,
            label: 'Kitchen Display',
            route: AppRoutes.kds,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.inventory,
            label: 'Inventory',
            route: AppRoutes.inventory,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.local_shipping,
            label: 'Suppliers',
            route: AppRoutes.suppliers,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.reviews,
            label: 'Reviews',
            route: AppRoutes.reviews,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.people,
            label: 'Users',
            route: AppRoutes.users,
            context: context,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings,
            label: 'Settings',
            route: AppRoutes.settings,
            context: context,
          ),
        ],
      ),
    );
  }

  /// Builds a single item for the navigation drawer.
  ///
  /// [icon]    – icon displayed on the left.
  /// [label]   – display text.
  /// [route]   – named route to navigate when the item is tapped.
  /// [context] – build context used for navigation.
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required String route,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade800),
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      onTap: () {
        // Close the drawer before navigating to the new screen.
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  // -------------------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------------------

  /// Displays a confirmation dialog and performs logout if confirmed.
  ///
  /// On confirmation:
  ///   1. Dismisses the dialog.
  ///   2. Calls [AuthManager.logout()] to clear local authentication state.
  ///   3. Replaces the current screen with the login screen.
  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthManager>().logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
