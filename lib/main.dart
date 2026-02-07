import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/auth/screens/login_screen.dart';
import 'package:restaurant_mobile_app/presentation/dashboard/screens/home_screen.dart';
import 'package:restaurant_mobile_app/presentation/users/screens/users_screen.dart';
import 'package:restaurant_mobile_app/presentation/suppliers/screens/suppliers_screen.dart';
import 'package:restaurant_mobile_app/presentation/reviews/screens/reviews_screen.dart';
import 'package:restaurant_mobile_app/presentation/orders/screens/orders_screen.dart';
import 'package:restaurant_mobile_app/presentation/inventory/screens/inventory_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/menu_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/menu_item_details_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/add_menu_item_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/edit_menu_item_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/categories_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthManager>(
      create: (context) => get<AuthManager>()..initialize(),
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
            home: _buildHomeScreen(authManager),
            routes: _buildRoutes(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AuthManager authManager) {
    if (authManager.isLoading && !authManager.isInitialized) {
      return const SplashScreen();
    }

    if (!authManager.isAuthenticated) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.users: (context) => const UsersScreen(),
      AppRoutes.suppliers: (context) => const SuppliersScreen(),
      AppRoutes.reviews: (context) => const ReviewsScreen(),
      AppRoutes.orders: (context) => const OrdersScreen(),
      AppRoutes.inventory: (context) => const InventoryScreen(),
      AppRoutes.menu: (context) => const MenuScreen(),
      AppRoutes.menuItemDetails: (context) {
        final menuItemId =
            ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return MenuItemDetailsScreen(menuItemId: menuItemId);
      },
      AppRoutes.addMenuItem: (context) => const AddMenuItemScreen(),
      AppRoutes.editMenuItem: (context) {
        final menuItemId =
            ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return EditMenuItemScreen(menuItemId: menuItemId);
      },
      AppRoutes.menuCategories: (context) => const CategoriesScreen(),
    };
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
