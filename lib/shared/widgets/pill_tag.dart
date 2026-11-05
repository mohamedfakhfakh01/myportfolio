import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Petite étiquette en forme de **pilule** (chip), fidèle au design.
///
/// Fond teinté doux (la couleur d'accent en très transparent), texte de la même
/// couleur d'accent, fine bordure et coins totalement arrondis. Réutilisée pour
/// les catégories de compétences, le langage d'un dépôt, etc.
class PillTag extends StatelessWidget {
  const PillTag({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  /// Texte affiché dans la pilule.
  final String label;

  /// Couleur d'accent (texte, pastille et teinte du fond). Défaut : bleu.
  final Color? color;

  /// Icône optionnelle avant le texte (ex : pastille `Icons.circle`).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.primary;
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
