import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/add_menu_item_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/edit_menu_item_screen.dart';
import 'package:restaurant_mobile_app/presentation/menu/screens/menu_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.menu:
        return MaterialPageRoute(builder: (_) => const MenuScreen());
      case AppRoutes.addMenuItem:
        return MaterialPageRoute(builder: (_) => const AddMenuItemScreen());
      case AppRoutes.editMenuItem:
        final menuItemId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditMenuItemScreen(menuItemId: menuItemId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
