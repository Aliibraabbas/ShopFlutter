import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'catalog_view_model.dart';
import '../../cart/presentation/cart_view_model.dart';
import '../../../app/theme_view_model.dart';


String _normalize(String value) => value.toLowerCase().trim();

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool _initialized = false;
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<CatalogViewModel>().loadProducts();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogViewModel>();
    final cartVm = context.watch<CartViewModel>();

    final allProducts = vm.products;
    final filteredProducts = allProducts.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _normalize(_searchQuery);
      return _normalize(p.title).contains(q) ||
          _normalize(p.category).contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person),
          ),
          Builder(builder: (context) {
            final themeVm = context.watch<ThemeViewModel>();
              IconData icon;
            switch (themeVm.mode) {
              case AppThemeMode.light:
                icon = Icons.light_mode;
                break;
              case AppThemeMode.dark:
                icon = Icons.dark_mode;
                break;
              case AppThemeMode.system:
                icon = Icons.brightness_auto;
                break;
            }

            return IconButton(
              tooltip: 'Changer de thème',
              icon: Icon(icon),
              onPressed: () => themeVm.toggleMode(),
            );
          }),
          IconButton(
            tooltip: 'Commandes',
            onPressed: () => context.go('/orders'),
            icon: const Icon(Icons.receipt_long),
          ),
          Badge.count(
            count: cartVm.totalItems,
            isLabelVisible: cartVm.totalItems > 0,
            alignment: Alignment.topRight,
            child: IconButton(
              tooltip: 'Panier',
              onPressed: () => context.go('/cart'),
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoadingList) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.listError != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Erreur : ${vm.listError}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CatalogViewModel>().loadProducts(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (vm.products.isEmpty) {
            return const Center(child: Text('Aucun produit.'));
          }

          if (filteredProducts.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Rechercher un produit',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const Expanded(
                  child: Center(
                    child:
                        Text('Aucun produit ne correspond à la recherche.'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un produit',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return ListTile(
                      leading: SizedBox(
                        height: 56,
                        width: 56,
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(product.title),
                      subtitle: Text(
                        '${product.price.toStringAsFixed(2)} €',
                      ),
                      onTap: () => context.go('/product/${product.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
