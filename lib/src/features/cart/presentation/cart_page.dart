import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/cart_view_model.dart';
import 'package:go_router/go_router.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
      ),
      body: vm.items.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.items.length,
                    itemBuilder: (context, index) {
                      final item = vm.items[index];
                      return ListTile(
                        leading: SizedBox(
                          height: 48,
                          width: 48,
                          child: Image.network(
                            item.product.thumbnail,
                            fit: BoxFit.cover,
                            // ignore: unnecessary_underscores
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(item.product.title),
                        subtitle: Text(
                          'Qté: ${item.quantity}  •  '
                          '${item.product.price.toStringAsFixed(2)} €',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              vm.removeFromCart(item.product.id),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${vm.totalPrice.toStringAsFixed(2)} €',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vm.items.isEmpty
                              ? null
                              : () {
                                  context.go('/checkout');
                                },
                          child: const Text('Passer au paiement'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
