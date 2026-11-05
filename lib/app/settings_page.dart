import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'theme/app_colors.dart';
import 'theme/theme_controller.dart';

/// Page **Réglages** : les préférences de l'application.
///
/// Choix du thème (clair/sombre) et de la langue (français/anglais), tous deux
/// mémorisés entre les lancements.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final ThemeController theme = context.watch<ThemeController>();
    final LocaleController locale = context.watch<LocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 112),
        children: [
          _sectionHeader(context, l.appearance),
          SwitchListTile(
            value: theme.isDark,
            onChanged: (_) => context.read<ThemeController>().toggle(),
            secondary: Icon(
              theme.isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: Text(l.darkTheme),
            subtitle: Text(theme.isDark ? l.darkThemeOn : l.darkThemeOff),
          ),
          const SizedBox(height: 8),
          _sectionHeader(context, l.language),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'fr', label: Text('Français')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {locale.isFrench ? 'fr' : 'en'},
              onSelectionChanged: (selection) => context
                  .read<LocaleController>()
                  .setLocale(Locale(selection.first)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
