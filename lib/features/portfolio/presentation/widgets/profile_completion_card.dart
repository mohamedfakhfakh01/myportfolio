import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/profile_completion.dart';

/// Carte « Complétion du profil » : grand bandeau en dégradé indigo → violet
/// avec un anneau de progression, le titre et le détail chiffré.
///
/// Le pourcentage est **calculé depuis les champs réellement remplis**
/// (voir [profileCompletion]) : ce n'est pas un score inventé.
class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({
    super.key,
    required this.completion,
    this.onTap,
  });

  final ProfileCompletion completion;

  /// Action au toucher (ex : afficher ce qu'il reste à renseigner).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    final Widget card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.violet],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Anneau de progression avec le pourcentage au centre.
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: completion.fraction),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.28),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                Text(
                  '${completion.percent}%',
                  style: text.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.profileCompletionTitle,
                  style: text.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.profileCompletionSubtitle(
                    completion.done,
                    completion.total,
                  ),
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    // Toute la carte est cliquable : un appui ouvre le détail des manquants.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
