import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/profile_completion.dart';

/// Libellé **traduit** d'un critère de complétion.
String profileCriterionLabel(AppLocalizations l, ProfileCriterion criterion) {
  switch (criterion) {
    case ProfileCriterion.photo:
      return l.criterionPhoto;
    case ProfileCriterion.bio:
      return l.criterionBio;
    case ProfileCriterion.email:
      return l.criterionEmail;
    case ProfileCriterion.phone:
      return l.criterionPhone;
    case ProfileCriterion.linkedin:
      return l.criterionLinkedin;
    case ProfileCriterion.location:
      return l.criterionLocation;
    case ProfileCriterion.github:
      return l.criterionGithub;
    case ProfileCriterion.skills:
      return l.criterionSkills;
    case ProfileCriterion.projects:
      return l.criterionProjects;
    case ProfileCriterion.experience:
      return l.criterionExperience;
    case ProfileCriterion.education:
      return l.criterionEducation;
  }
}

/// Ouvre la feuille listant ce qu'il reste à renseigner pour atteindre 100 %.
Future<void> showProfileCompletionSheet(
  BuildContext context,
  ProfileCompletion completion,
) {
  return showModalBottomSheet<void>(
    context: context,
    // La feuille grandit avec son contenu (au lieu d'être bloquée à 9/16 de
    // l'écran), sans passer sous la barre d'état ni l'encoche.
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProfileCompletionSheet(completion: completion),
  );
}

class _ProfileCompletionSheet extends StatelessWidget {
  const _ProfileCompletionSheet({required this.completion});

  final ProfileCompletion completion;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      // Défile si la liste dépasse l'écran : un portfolio tout juste créé a
      // 11 critères manquants, qui ne tenaient pas tous (contenu coupé).
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : pourcentage et décompte.
            Row(
              children: [
                Text(
                  '${completion.percent}%',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.profileCompletionSubtitle(
                      completion.done,
                      completion.total,
                    ),
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Barre de progression en dégradé (même langage que les niveaux).
            LayoutBuilder(
              builder: (context, constraints) => Container(
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * completion.fraction,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.violet],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            if (completion.isComplete)
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.completionAllDone, style: text.bodyLarge),
                  ),
                ],
              )
            else ...[
              Text(
                l.completionMissingTitle,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final criterion in completion.missing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profileCriterionLabel(l, criterion),
                          style: text.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
