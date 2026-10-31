import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/skill.dart';
import 'skill_category_label.dart';

/// Camembert (donut) de **répartition des compétences par catégorie**.
///
/// Chaque part du donut représente le **nombre** de compétences d'une
/// catégorie (Langages, Frameworks, Outils, Autres). On n'utilise que des
/// données réelles — la catégorie de chaque compétence — donc **aucune valeur
/// inventée** : contrairement au niveau (souvent `null`), la catégorie existe
/// toujours.
///
/// Seules les catégories réellement présentes sont dessinées. Si la liste de
/// compétences est vide, le widget ne rend rien.
class SkillsCategoryChart extends StatelessWidget {
  const SkillsCategoryChart({super.key, required this.skills});

  final List<Skill> skills;

  /// Couleur attribuée à chaque catégorie. Choisies distinctes et lisibles
  /// aussi bien en thème clair qu'en sombre (les parts sont pleines).
  static const Map<SkillCategory, Color> _categoryColors = {
    SkillCategory.language: Color(0xFF3B82F6), // bleu
    SkillCategory.framework: Color(0xFF22D3EE), // cyan
    SkillCategory.tool: Color(0xFF8B5CF6), // violet
    SkillCategory.other: Color(0xFFF59E0B), // ambre
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    // Compte des compétences par catégorie, dans l'ordre de l'enum, en ne
    // gardant que les catégories réellement présentes.
    final List<MapEntry<SkillCategory, int>> counts = [
      for (final category in SkillCategory.values)
        if (skills.any((s) => s.category == category))
          MapEntry(
            category,
            skills.where((s) => s.category == category).length,
          ),
    ];

    // Rien à dessiner s'il n'y a aucune compétence.
    if (counts.isEmpty) return const SizedBox.shrink();

    final int total = skills.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // --- Le donut, avec le total affiché en son centre ---
          SizedBox(
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 46,
                    sections: [
                      for (final entry in counts)
                        PieChartSectionData(
                          value: entry.value.toDouble(),
                          color: _categoryColors[entry.key],
                          radius: 36,
                          title: '${entry.value}',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                // Total des compétences, au creux du donut.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: text.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l.skills.toLowerCase(),
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // --- Légende : pastille colorée + libellé + compte par catégorie ---
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final entry in counts)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _categoryColors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${skillCategoryLabel(l, entry.key)} (${entry.value})',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
