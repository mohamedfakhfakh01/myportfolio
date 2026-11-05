import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/skill.dart';

/// Affiche une compétence avec une **barre de niveau** quand le niveau est
/// renseigné (sinon, seulement le nom — on n'invente pas de valeur).
class SkillLevelTile extends StatelessWidget {
  const SkillLevelTile({super.key, required this.skill, this.onTap});

  final Skill skill;

  /// Action au toucher (ex : ouvrir la modification). Si null, non cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int? level = skill.level;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(skill.name, style: text.bodyLarge)),
                if (level != null)
                  Text(
                    '$level%',
                    style: text.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            if (level != null) ...[
              const SizedBox(height: 8),
              _GradientLevelBar(value: level.clamp(0, 100) / 100),
            ],
          ],
        ),
      ),
    );
  }
}

/// Barre de niveau en **pilule** avec remplissage en dégradé bleu → violet
/// (fidèle au design). La largeur du remplissage s'anime à l'apparition.
class _GradientLevelBar extends StatelessWidget {
  const _GradientLevelBar({required this.value});

  /// Valeur entre 0 et 1.
  final double value;

  @override
  Widget build(BuildContext context) {
    const double height = 7;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.border, // piste neutre
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) => Container(
                width: maxWidth * animatedValue,
                height: height,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.violet],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
