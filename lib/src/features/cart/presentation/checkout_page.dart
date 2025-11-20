import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../presentation/cart_view_model.dart';
import '../../orders/presentation/orders_view_model.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartVm.items.isEmpty
          ? const Center(
              child: Text('Votre panier est vide.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartVm.items.length,
                      itemBuilder: (context, index) {
                        final item = cartVm.items[index];
                        return ListTile(
                          title: Text(item.product.title),
                          subtitle: Text(
                            'Qté: ${item.quantity} • '
                            '${item.product.price.toStringAsFixed(2)} €',
                          ),
                          trailing: Text(
                            '${item.totalPrice.toStringAsFixed(2)} €',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total à payer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${cartVm.totalPrice.toStringAsFixed(2)} €',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ordersVm =
                            context.read<OrdersViewModel>();

                        await ordersVm.createOrderFromCart(cartVm);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Commande créée (mock paiement)'),
                            ),
                          );
                          context.go('/catalog');
                        }
                      },
                      child: const Text('Confirmer la commande'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
