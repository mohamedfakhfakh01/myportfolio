import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../features/portfolio/domain/portfolio_backup.dart';
import '../features/portfolio/providers/portfolio_provider.dart';
import '../l10n/app_localizations.dart';
import '../shared/models/student.dart';
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
          const SizedBox(height: 8),
          _sectionHeader(context, l.backupSection),
          ListTile(
            leading: const Icon(
              Icons.ios_share_outlined,
              color: AppColors.primary,
            ),
            title: Text(l.exportData),
            subtitle: Text(l.exportDataSubtitle),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.file_download_outlined,
              color: AppColors.primary,
            ),
            title: Text(l.importData),
            subtitle: Text(l.importDataSubtitle),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }

  /// Écrit tous les portfolios dans un fichier JSON et ouvre le partage iOS
  /// (mail, Fichiers, AirDrop…) pour que l'utilisateur le conserve.
  Future<void> _exportData(BuildContext context) async {
    // On capture l et le messenger AVANT les await (ne pas réutiliser
    // `context` à travers une opération asynchrone).
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final List<Student> students = context.read<PortfolioProvider>().students;

    try {
      final Directory dir = await getTemporaryDirectory();
      final DateTime now = DateTime.now();
      final String stamp =
          '${now.year}-${_two(now.month)}-${_two(now.day)}';
      final File file = File('${dir.path}/myportfolio_$stamp.json');
      await file.writeAsString(encodePortfolioBackup(students));
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: l.exportData),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.exportError)));
    }
  }

  /// Importe une sauvegarde choisie par l'utilisateur. Les portfolios du
  /// fichier **s'ajoutent** aux existants : rien n'est écrasé.
  Future<void> _importData(BuildContext context) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final PortfolioProvider provider = context.read<PortfolioProvider>();

    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (files.isEmpty) return; // l'utilisateur a annulé
      final String? path = files.first.path;
      if (path == null) return;

      final String source = await File(path).readAsString();
      final int count =
          await provider.importStudents(decodePortfolioBackup(source));
      messenger.showSnackBar(SnackBar(content: Text(l.importSuccess(count))));
    } on FormatException {
      // Fichier lisible mais qui n'est pas une sauvegarde valide.
      messenger.showSnackBar(SnackBar(content: Text(l.importInvalid)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.importError)));
    }
  }

  /// Deux chiffres (pour la date du nom de fichier).
  String _two(int n) => n.toString().padLeft(2, '0');

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
