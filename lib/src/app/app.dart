import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/src/app/theme_view_model.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/catalog/data/catalog_repository.dart';
import '../features/catalog/presentation/catalog_view_model.dart';
import '../features/cart/presentation/cart_view_model.dart';
import '../features/orders/data/orders_repository.dart';
import '../features/orders/presentation/orders_view_model.dart';
import 'router.dart';

class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider<AuthRouterNotifier>(
          create: (_) => AuthRouterNotifier(),
        ),

        // Catalog
        Provider<CatalogRepository>(
          create: (_) => CatalogRepository(),
        ),
        ChangeNotifierProvider<CatalogViewModel>(
          create: (context) => CatalogViewModel(
            repository: context.read<CatalogRepository>(),
          ),
        ),

        // Cart
        ChangeNotifierProvider<CartViewModel>(
          create: (_) => CartViewModel(),
        ),

        // Orders
        Provider<OrdersRepository>(
          create: (_) => OrdersRepository(),
        ),
        ChangeNotifierProvider<OrdersViewModel>(
          create: (context) => OrdersViewModel(
            repository: context.read<OrdersRepository>(),
          )..loadOrders(),
        ),

        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),

      ],
      child: Builder(
        builder: (context) {
          final authNotifier = context.watch<AuthRouterNotifier>();

          final lightTheme = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          );

          final darkTheme = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'ShopFlutter',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: context.watch<ThemeViewModel>().flutterThemeMode,
            routerConfig: createRouter(authNotifier),
          );
        },
      ),
    );
  }
}
