// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/catalog/presentation/catalog_page.dart';
import '../features/catalog/presentation/product_detail_page.dart';
import '../features/cart/presentation/cart_page.dart';
import '../features/cart/presentation/checkout_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/profile/presentation/profile_page.dart';


import 'app.dart'; // pour AuthRouterNotifier

GoRouter createRouter(AuthRouterNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/catalog',
    debugLogDiagnostics: true,

    refreshListenable: authNotifier,

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

    ],

    redirect: (context, state) {
      final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final String location = state.matchedLocation;

      final bool goingToAuth =
          location == '/login' || location == '/register';

      if (!isLoggedIn && !goingToAuth) {
        return '/login';
      }

      if (isLoggedIn && goingToAuth) {
        return '/catalog';
      }

      return null;
    },
  );
}
