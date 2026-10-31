import 'package:flutter/material.dart';

import '../features/portfolio/presentation/pages/home_page.dart';
import '../l10n/app_localizations.dart';
import 'about_page.dart';
import 'settings_page.dart';

/// Coquille principale de l'application : une **barre de navigation en bas**
/// (Material 3) qui bascule entre trois onglets.
///
/// On utilise un [IndexedStack] : les trois pages restent vivantes en mémoire,
/// donc on retrouve l'état de chaque onglet (recherche, défilement…) en y
/// revenant, sans le reconstruire.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _pages = [
    HomePage(),
    AboutPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: l.navAbout,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
