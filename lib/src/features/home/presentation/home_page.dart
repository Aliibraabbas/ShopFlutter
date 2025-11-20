import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/catalog'),
              child: const Text('Voir le catalogue'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/cart'),
              child: const Text('Voir le panier'),
            ),
          ],
        ),
      ),
    );
  }
}
