import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'theme/app_colors.dart';

/// Page **À propos** : présente l'application et ses fonctionnalités.
///
/// On n'y met que des informations vérifiées (ce que l'app fait réellement),
/// pas de données inventées.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.navAbout)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.badge_outlined, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('MyPortfolio', style: text.headlineSmall)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l.aboutSubtitle,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 28),

          Text(l.aboutWhatTitle, style: text.titleMedium),
          const SizedBox(height: 10),
          _Bullet(l.aboutFeature1),
          _Bullet(l.aboutFeature2),
          _Bullet(l.aboutFeature3),
          _Bullet(l.aboutFeature4),
          _Bullet(l.aboutFeature5),
          const SizedBox(height: 24),

          Text(l.aboutTechTitle, style: text.titleMedium),
          const SizedBox(height: 10),
          _Bullet(l.aboutTech1),
          _Bullet(l.aboutTech2),
          _Bullet(l.aboutTech3),
          const SizedBox(height: 24),

          Text(
            l.aboutFooter,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Un point de liste avec une puce bleue.
class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 10),
            child: Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          ),
          Expanded(child: Text(text, style: t.bodyMedium)),
        ],
      ),
    );
  }
}
