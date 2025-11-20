import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'orders_view_model.dart';

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _formatDate(DateTime date) {
  final d = _twoDigits(date.day);
  final m = _twoDigits(date.month);
  final y = date.year.toString();
  final h = _twoDigits(date.hour);
  final min = _twoDigits(date.minute);
  return '$d/$m/$y $h:$min';
}

String _formatDay(DateTime date) {
  final d = _twoDigits(date.day);
  final m = _twoDigits(date.month);
  final y = date.year.toString();
  return '$d/$m/$y';
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrdersViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
      ),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Erreur : ${vm.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: vm.loadOrders,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (vm.orders.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez pas encore de commande.'),
            );
          }

          // On injecte des "headers" de date dans la liste
          final widgets = <Widget>[];
          DateTime? lastDay;

          for (final order in vm.orders) {
            final day = DateUtils.dateOnly(order.createdAt);
            final isNewDay =
                lastDay == null || day.isBefore(lastDay) || day != lastDay;

            if (isNewDay) {
              lastDay = day;
              widgets.add(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    _formatDay(day),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            final nbArticles = order.items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );

            widgets.add(
              Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text(
                    'Commande #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_formatDate(order.createdAt)} • '
                    '$nbArticles article(s) • '
                    '${order.total.toStringAsFixed(2)} €',
                  ),
                  children: [
                    const Divider(),
                    ...order.items.map((item) {
                      return ListTile(
                        title: Text(item.product.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Qté: ${item.quantity} • '
                              '${item.product.price.toStringAsFixed(2)} €',
                            ),
                            TextButton(
                              onPressed: () => context
                                  .go('/product/${item.product.id}'),
                              child: const Text('Voir la fiche produit'),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${item.totalPrice.toStringAsFixed(2)} €',
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadOrders,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: widgets,
            ),
          );
        },
      ),
    );
  }
}
