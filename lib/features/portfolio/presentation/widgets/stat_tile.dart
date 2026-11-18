import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Petite tuile de statistique : une icône, un grand chiffre et un libellé.
///
/// Utilisée en rangée sur le profil pour montrer d'un coup d'œil le nombre de
/// compétences, de projets, etc.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Mise en avant : fond indigo doux et sans bordure (style du design).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: highlighted ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
