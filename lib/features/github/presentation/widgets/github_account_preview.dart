import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/github_repo.dart';
import '../../../../l10n/app_localizations.dart';


/// Aperçu sous le champ GitHub : la preuve que c'est le bon compte, avec ses
/// derniers dépôts publics (les plus récemment mis à jour d'abord).
class GithubAccountPreview extends StatelessWidget {
  const GithubAccountPreview({
    super.key,
    required this.loading,
    required this.repos,
    required this.unknown,
  });

  final bool loading;
  final List<GithubRepo>? repos;
  final bool unknown;

  /// Nombre de dépôts listés ; les autres sont résumés en « + N autres ».
  static const int _shown = 5;

  /// Nombre maximal demandé à GitHub ; au-delà, on ne connaît pas le total.
  static const int _fetched = 100;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    Widget line(Widget icon, String label, {Color? color}) => Padding(
          padding: const EdgeInsets.only(top: 8, left: 12),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: text.bodySmall?.copyWith(color: color)),
              ),
            ],
          ),
        );

    if (loading) {
      return line(
        const SizedBox.square(
          dimension: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        l.githubPreviewLoading,
      );
    }
    if (unknown) {
      return line(
        Icon(Icons.cloud_off_outlined, size: 16, color: colors.outline),
        l.githubPreviewUnknown,
        color: colors.outline,
      );
    }
    final List<GithubRepo>? found = repos;
    if (found == null) return const SizedBox.shrink();

    final int more = found.length - _shown;
    final Color accent = AppColors.primaryText; // lisible dans les 2 thèmes
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.githubPreviewFound,
                    style: text.labelLarge?.copyWith(color: accent)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (found.isEmpty)
            Text(l.githubPreviewNoRepos, style: text.bodySmall)
          else ...[
            for (final GithubRepo repo in found.take(_shown))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.book_outlined, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        repo.name,
                        style: text.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (repo.language != null) ...[
                      const SizedBox(width: 8),
                      Text(repo.language!, style: text.bodySmall),
                    ],
                  ],
                ),
              ),
            if (more > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  // 100 dépôts reçus = la limite : le vrai total est inconnu.
                  found.length >= _fetched
                      ? l.githubPreviewManyMore
                      : l.githubPreviewMore(more),
                  style: text.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
