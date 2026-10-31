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
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
            if (level != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: level.clamp(0, 100) / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.primarySoft,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
