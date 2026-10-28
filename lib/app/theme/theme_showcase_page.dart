import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Écran VITRINE de l'identité visuelle (TEMPORAIRE).
///
/// Son seul but est de permettre de *voir* le thème en action : couleurs,
/// police Poppins, boutons, carte, puces (chips) et champ de saisie.
/// Il sera SUPPRIMÉ / remplacé par le vrai écran d'accueil à l'étape 6.
///
/// Note pédagogique : aucune donnée réelle ici, uniquement des éléments de
/// démonstration pour valider le style.
class ThemeShowcasePage extends StatelessWidget {
  const ThemeShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    // `Theme.of(context)` récupère le thème courant pour réutiliser ses styles
    // de texte (titres, etc.) au lieu de réécrire les tailles à la main.
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('MyPortfolio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identité visuelle', style: text.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Aperçu du thème (écran temporaire)',
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // --- Carte de profil (démonstration) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        'MF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mohamed Fakhfakh',
                            style: text.titleMedium),
                        Text(
                          '2e année informatique',
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Puces de compétences (chips) ---
            Text('Compétences', style: text.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _SkillChip(label: 'Flutter'),
                _SkillChip(label: 'Dart', accent: true),
                _SkillChip(label: 'Java'),
              ],
            ),
            const SizedBox(height: 24),

            // --- Champ de saisie (démonstration) ---
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nom du projet',
                hintText: 'Ex : MyPortfolio',
              ),
            ),
            const SizedBox(height: 24),

            // --- Boutons ---
            ElevatedButton(
              onPressed: () {},
              child: const Text('Action principale'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Action secondaire'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petite puce (chip) de compétence réutilisable dans cette vitrine.
///
/// `accent: true` utilise la couleur cyan au lieu de l'indigo.
class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final Color bg = accent ? AppColors.accentSoft : AppColors.primarySoft;
    final Color fg = accent ? AppColors.accentDark : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w500),
      ),
    );
  }
}
