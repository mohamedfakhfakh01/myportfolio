import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../features/portfolio/presentation/pages/home_page.dart';
import '../l10n/app_localizations.dart';
import 'about_page.dart';
import 'settings_page.dart';

/// Coquille principale de l'application : une **barre de navigation flottante**
/// (deck « obsidienne » du design Stitch) qui bascule entre trois onglets.
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
          _NavSpec(Icons.home_outlined, Icons.home, l.navHome),
          _NavSpec(Icons.info_outline, Icons.info, l.navAbout),
          _NavSpec(Icons.settings_outlined, Icons.settings, l.navSettings),
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

/// Deck de navigation **flottant** : fond sombre « obsidienne » translucide et
/// flouté, coins en pilule, posé à 1 cm du bas (au-dessus de la zone sûre).
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.index,
    required this.onSelected,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final List<_NavSpec> items;

  // Couleurs du deck : sombre « obsidienne ». En thème sombre, le fond de
  // l'app est déjà #0F172A : on éclaircit un peu le deck (et on ajoute une fine
  // bordure) pour qu'il reste visible.
  static const Color _resting = Color(0xFF94A3B8); // slate
  static const Color _active = Color(0xFF38BDF8); // cyan ciel

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color deck =
        isDark ? const Color(0xF21E293B) : const Color(0xEB0F172A);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: deck,
                borderRadius: BorderRadius.circular(999),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                    : null,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F0F172A),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavItem(
                        spec: items[i],
                        selected: i == index,
                        activeColor: _active,
                        restingColor: _resting,
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

/// Un onglet du deck : icône + libellé, avec un point lumineux quand il est
/// actif (icône et texte passent en cyan).
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.selected,
    required this.activeColor,
    required this.restingColor,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final Color activeColor;
  final Color restingColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color color = selected ? activeColor : restingColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? spec.selectedIcon : spec.icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Point lumineux sous l'onglet actif (indicateur du design).
            Container(
              width: 5,
              height: 5,
              decoration: selected
                  ? BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ],
                    )
                  : const BoxDecoration(),
            ),
          ],
        ),
      ),
    );
  }
}
