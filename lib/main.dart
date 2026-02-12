// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/presentation/auth/screens/login_screen.dart';
import 'package:restaurant_mobile_app/presentation/dashboard/screens/home_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/menu_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/add_menu_item_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/edit_menu_item_screen.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';
import 'package:restaurant_mobile_app/presentation/orders/screens/orders_screen.dart';
import 'package:restaurant_mobile_app/presentation/orders/view_models/orders_view_model.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';
import 'package:restaurant_mobile_app/presentation/kds/screens/kds_screen.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/presentation/orders/screens/order_detail_screen.dart';
import 'package:restaurant_mobile_app/presentation/orders/screens/waiter_order_screen.dart';
import 'package:restaurant_mobile_app/presentation/inventory/screens/inventory_screen.dart';
import 'package:restaurant_mobile_app/presentation/suppliers/screens/suppliers_screen.dart';
import 'package:restaurant_mobile_app/presentation/reviews/screens/reviews_screen.dart';
import 'package:restaurant_mobile_app/presentation/users/screens/users_screen.dart';
import 'package:restaurant_mobile_app/presentation/settings/screens/settings_screen.dart';
import 'package:restaurant_mobile_app/presentation/users/view_models/users_view_model.dart';
import 'package:restaurant_mobile_app/presentation/users/managers/user_manager.dart';

// -----------------------------------------------------------------------------
// Application Entry Point
// -----------------------------------------------------------------------------

/// Initialises the dependency injection container and runs the [RestaurantApp].
///
/// This function is called once when the application starts. It ensures that
/// Flutter’s binding is initialised, sets up all dependencies via [setupInjector],
/// and then starts the widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const RestaurantApp());
}

// -----------------------------------------------------------------------------
// Splash Screen
// -----------------------------------------------------------------------------

/// A simple full‑screen splash screen displayed while the [AuthManager]
/// initialises and checks the authentication state.
///
/// This widget shows a centered [CircularProgressIndicator] and is used as
/// a temporary placeholder during app startup.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// -----------------------------------------------------------------------------
// Root Application Widget
// -----------------------------------------------------------------------------

/// The root widget of the Restaurant Management application.
///
/// This widget sets up the global providers ([AuthManager], [MenuViewModel])
/// and builds the [MaterialApp] with conditional routing based on the
/// authentication state. It also defines all named routes used throughout
/// the application.
///
/// The app’s theme is configured with Material 3 and a light blue colour scheme.
class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Global providers that must be available to the entire app.
    return MultiProvider(
      providers: [
        // AuthManager is responsible for authentication state and token.
        ChangeNotifierProvider<AuthManager>(
          create: (context) => get<AuthManager>()..initialize(),
        ),
        // MenuViewModel is provided globally because many parts of the app
        // (menu, KDS, orders) need access to menu data.
        ChangeNotifierProvider(create: (context) => get<MenuViewModel>()),
      ],
      child: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          return MaterialApp(
            title: 'Restaurant Manager',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            // The home screen is determined by the current authentication state.
            home: _buildHomeScreen(authManager),
            // All named routes are defined here.
            routes: _buildRoutes(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  /// Returns the appropriate home screen based on the [AuthManager] state.
  ///
  /// - While the auth manager is initialising and still loading: [SplashScreen].
  /// - If the user is not authenticated: [LoginScreen].
  /// - Otherwise (authenticated): [HomeScreen].
  Widget _buildHomeScreen(AuthManager authManager) {
    if (authManager.isLoading && !authManager.isInitialized) {
      return const SplashScreen();
    }
    if (!authManager.isAuthenticated) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }

  /// Builds the complete route table for the application.
  ///
  /// Routes are grouped by feature area for better readability and maintenance.
  /// Some routes (e.g., `AppRoutes.users`, `AppRoutes.orders`) require dynamic
  /// dependency injection and therefore are built with a [ChangeNotifierProvider]
  /// to supply the necessary ViewModels.
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      // -----------------------------------------------------------------------
      // Authentication & Onboarding
      // -----------------------------------------------------------------------
      AppRoutes.login: (context) => const LoginScreen(),

      // -----------------------------------------------------------------------
      // Dashboard & Core
      // -----------------------------------------------------------------------
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),

      // -----------------------------------------------------------------------
      // Menu Management
      // -----------------------------------------------------------------------
      AppRoutes.menu: (context) => const MenuScreen(),
      AppRoutes.addMenuItem: (context) => const AddMenuItemScreen(),
      AppRoutes.editMenuItem: (context) {
        final menuItemId =
            ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return EditMenuItemScreen(menuItemId: menuItemId);
      },

      // -----------------------------------------------------------------------
      // Order & KDS (Kitchen Display System)
      // -----------------------------------------------------------------------
      AppRoutes.orders: (context) {
        // Orders screen requires a ViewModel that depends on OrderManager and token.
        return ChangeNotifierProvider<OrdersViewModel>(
          create: (context) {
            final authToken = context.read<AuthManager>().token;
            final orderManager = get<OrderManager>();
            return OrdersViewModel(orderManager, authToken);
          },
          child: const OrdersScreen(),
        );
      },
      AppRoutes.orderDetails: (context) {
        // Expects an OrderEntity passed as a route argument.
        final order =
            ModalRoute.of(context)?.settings.arguments as OrderEntity?;
        if (order == null) {
          return const Scaffold(
            body: Center(child: Text('Order data not found')),
          );
        }
        return OrderDetailScreen(order: order);
      },
      AppRoutes.createOrder: (context) => const WaiterOrderScreen(),
      AppRoutes.kds: (context) => const KDSScreen(),

      // -----------------------------------------------------------------------
      // User Management (Admin only)
      // -----------------------------------------------------------------------
      AppRoutes.users: (context) {
        final authManager = context.watch<AuthManager>();
        final token = authManager.token;

        // While the auth manager is not ready, show a loading indicator.
        if (!authManager.isInitialized || authManager.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the token is null (unauthenticated), show an error.
        // In practice, this route should never be reachable when unauthenticated.
        if (token == null) {
          return const Scaffold(
            body: Center(child: Text('Authentication required')),
          );
        }

        return ChangeNotifierProvider<UsersViewModel>(
          create: (_) =>
              UsersViewModel(userManager: get<UserManager>(), authToken: token),
          child: const UsersScreen(),
        );
      },

      // -----------------------------------------------------------------------
      // Inventory & Suppliers
      // -----------------------------------------------------------------------
      AppRoutes.inventory: (context) => const InventoryScreen(),
      AppRoutes.suppliers: (context) => const SuppliersScreen(),

      // -----------------------------------------------------------------------
      // Reviews & Feedback
      // -----------------------------------------------------------------------
      AppRoutes.reviews: (context) => const ReviewsScreen(),
    };
  }
}
