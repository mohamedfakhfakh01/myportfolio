import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/skill.dart';

/// Renvoie le libellé **traduit** d'une catégorie de compétence.
///
/// Le modèle [SkillCategory] ne connaît pas la langue : on traduit ici, au
/// moment de l'affichage, pour garder une seule source de vérité (les .arb).
String skillCategoryLabel(AppLocalizations l, SkillCategory category) {
  switch (category) {
    case SkillCategory.language:
      return l.catLanguages;
    case SkillCategory.framework:
      return l.catFrameworks;
    case SkillCategory.tool:
      return l.catTools;
    case SkillCategory.other:
      return l.catOther;
  }
}

/// Couleur d'accent associée à une catégorie (pour les pilules du design).
Color skillCategoryColor(SkillCategory category) {
  switch (category) {
    case SkillCategory.language:
      return AppColors.primary; // bleu
    case SkillCategory.framework:
      return AppColors.violet; // violet
    case SkillCategory.tool:
      return AppColors.accent; // cyan
    case SkillCategory.other:
      return AppColors.textSecondary; // slate
  }
}
