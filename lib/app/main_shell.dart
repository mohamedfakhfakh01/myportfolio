import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../features/portfolio/presentation/pages/home_page.dart';
import '../l10n/app_localizations.dart';
import 'about_page.dart';
import 'settings_page.dart';
import 'theme/app_colors.dart';

/// Coquille principale de l'application : une **barre de navigation flottante**
/// claire, dont l'onglet actif est une pilule en dégradé indigo → violet.
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
      // Le contenu passe DERRIÈRE la nav flottante → effet verre dépoli.
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _FloatingNavBar(
        index: _index,
        onSelected: (i) => setState(() => _index = i),
        items: [
          _NavSpec(Icons.home_outlined, Icons.home_rounded, l.navHome),
          _NavSpec(Icons.info_outline, Icons.info_rounded, l.navAbout),
          _NavSpec(Icons.settings_outlined, Icons.settings_rounded,
              l.navSettings),
        ],
      ),
    );
  }
}

/// Description d'un onglet (icône au repos, icône active, libellé).
class _NavSpec {
  const _NavSpec(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Barre de navigation **flottante** en pilule claire, posée au-dessus du
/// contenu (fond translucide flouté, fine bordure, ombre douce).
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.index,
    required this.onSelected,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final List<_NavSpec> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                // Surface du thème (blanche en clair) légèrement translucide.
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14312E81),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavItem(
                        spec: items[i],
                        selected: i == index,
                        onTap: () => onSelected(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un onglet : icône + libellé. L'onglet actif devient une **pilule en
/// dégradé indigo → violet** avec texte et icône blancs.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color color = selected ? Colors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.violet],
                )
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? spec.selectedIcon : spec.icon,
                color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
