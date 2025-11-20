import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeVm = context.watch<ThemeViewModel>();

    IconData themeIcon;
    String themeLabel;
    switch (themeVm.mode) {
      case AppThemeMode.light:
        themeIcon = Icons.light_mode;
        themeLabel = 'Thème clair';
        break;
      case AppThemeMode.dark:
        themeIcon = Icons.dark_mode;
        themeLabel = 'Thème sombre';
        break;
      case AppThemeMode.system:
      themeIcon = Icons.brightness_auto;
        themeLabel = 'Thème système';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.person, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'Utilisateur inconnu',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                if (user != null)
                  Text(
                    'UID : ${user.uid}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),

                // Bouton thème
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: themeVm.toggleMode,
                    icon: Icon(themeIcon),
                    label: Text('Changer de thème ($themeLabel)'),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton commandes
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/orders'),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Voir mes commandes'),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        // le guard te renverra de toute façon vers /login
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
