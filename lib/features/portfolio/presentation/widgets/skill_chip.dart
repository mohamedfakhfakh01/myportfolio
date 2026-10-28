import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/skill.dart';

/// Petite puce (chip) affichant une compétence.
///
/// Si la compétence a un niveau (`level` non nul), on l'ajoute au texte
/// (ex : « Flutter · 70% »). Sinon, on affiche seulement le nom — on n'invente
/// aucun niveau.
class SkillChip extends StatelessWidget {
  const SkillChip({super.key, required this.skill, this.onTap});

  final Skill skill;

  /// Action au toucher (ex : ouvrir la modification). Si null, la puce n'est
  /// pas cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String label =
        skill.level == null ? skill.name : '${skill.name} · ${skill.level}%';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
