import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/injector.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuViewModel>(
          create: (context) => get<MenuViewModel>(),
        ),
      ],
      child: child,
    );
  }
}
