import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/skill.dart';

/// Nombre de points pleins (sur 4) correspondant à un niveau en pourcentage.
///
/// 1–25 → 1 point, 26–50 → 2, 51–75 → 3, 76–100 → 4.
/// Un niveau absent ou nul donne 0 point : on n'invente aucune valeur.
int skillDots(int? level) {
  if (level == null || level <= 0) return 0;
  final int clamped = level > 100 ? 100 : level;
  return (clamped / 25).ceil().clamp(1, 4);
}

/// Compétence affichée en **chip** : le nom suivi d'un indicateur à 4 points
/// (style du design). Le pourcentage exact reste lisible dans l'info-bulle.
class SkillDotChip extends StatelessWidget {
  const SkillDotChip({super.key, required this.skill, this.onTap, this.color});

  final Skill skill;

  /// Action au toucher (ex : ouvrir la modification). Si null, non cliquable.
  final VoidCallback? onTap;

  /// Couleur des points pleins (par défaut : indigo principal).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color dotColor = color ?? AppColors.primary;
    final int filled = skillDots(skill.level);

    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          // Les points ne s'affichent que si un niveau est renseigné.
          if (skill.level != null) ...[
            const SizedBox(width: 12),
            for (int i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Container(
                width: 10,
                height: 5,
                decoration: BoxDecoration(
                  color: i < filled ? dotColor : AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ],
        ],
      ),
    );

    if (onTap == null) return chip;

    return Tooltip(
      // On ne perd pas la précision : le niveau exact reste consultable.
      message: skill.level != null ? '${skill.name} · ${skill.level}%' : skill.name,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: chip,
        ),
      ),
    );
  }
}
