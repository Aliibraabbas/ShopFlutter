import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'catalog_view_model.dart';
import '../../cart/presentation/cart_view_model.dart';
import '../domain/product.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final id = int.tryParse(widget.productId);
      if (id != null) {
        context.read<CatalogViewModel>().loadProductDetail(id);
      }
      _initialized = true;
    }
  }

  void _shareProduct(Product product) {
    final message =
        'Regarde ce produit : ${product.title} - '
        '${product.price.toStringAsFixed(2)} €';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogViewModel>();
    final cartVm = context.watch<CartViewModel>();

    final Product? product = vm.selectedProduct;
    final bool isLoading = vm.isLoadingDetail;
    final String? error = vm.detailError;

    Widget body;
    if (isLoading || (product == null && error == null)) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(child: Text('Erreur : $error'));
    } else {
      body = _ProductDetailContent(
        product: product!,
        cartVm: cartVm,
      );
    }

    final bool isIOS = !kIsWeb && Platform.isIOS;

    if (isIOS) {
      // iOS : Cupertino
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(product?.title ?? 'Produit'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _shareProduct(product),
                  child: const Icon(CupertinoIcons.share),
                ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/cart'),
                child: const Icon(CupertinoIcons.shopping_cart),
              ),
            ],
          ),
        ),
        child: SafeArea(child: body),
      );
    }

    // Android / Web
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.title ?? 'Produit ${widget.productId}'),
        actions: [
          if (product != null)
            IconButton(
              tooltip: 'Partager',
              onPressed: () => _shareProduct(product),
              icon: const Icon(Icons.share),
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
        ],
      ),
      body: body,
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final Product product;
  final CartViewModel cartVm;

  const _ProductDetailContent({
    required this.product,
    required this.cartVm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.network(
              product.thumbnail,
              height: 200,
              fit: BoxFit.contain,
              // ignore: unnecessary_underscores
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 80),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${product.price.toStringAsFixed(2)} €',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            'Catégorie : ${product.category}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                cartVm.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ajouté au panier')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Ajouter au panier'),
            ),
          ),
        ],
      ),
    );
  }
}
