import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/presentation/auth/screens/login_screen.dart';
import 'package:restaurant_mobile_app/presentation/dashboard/screens/home_screen.dart';
import 'package:restaurant_mobile_app/presentation/users/screens/users_screen.dart';
import 'package:restaurant_mobile_app/presentation/suppliers/screens/suppliers_screen.dart';
import 'package:restaurant_mobile_app/presentation/reviews/screens/reviews_screen.dart';
import 'package:restaurant_mobile_app/presentation/orders/screens/orders_screen.dart';
import 'package:restaurant_mobile_app/presentation/inventory/screens/inventory_screen.dart';

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/users': (context) => const UsersScreen(),
        '/suppliers': (context) => const SuppliersScreen(),
        '/reviews': (context) => const ReviewsScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/inventory': (context) => const InventoryScreen(),
      },
    );
  }
}
