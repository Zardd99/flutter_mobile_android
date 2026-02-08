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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthManager>(
          create: (context) => get<AuthManager>()..initialize(),
        ),
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
      AppRoutes.menu: (context) => const MenuScreen(),
      AppRoutes.addMenuItem: (context) => const AddMenuItemScreen(),
      AppRoutes.editMenuItem: (context) {
        final menuItemId =
            ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return EditMenuItemScreen(menuItemId: menuItemId);
      },
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
