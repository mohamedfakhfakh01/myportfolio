import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/github_repo.dart';
import '../../data/github_service.dart';
import 'github_repo_card.dart';

/// Section « Dépôts GitHub » du profil.
///
/// Appelle l'API GitHub (via [GithubService]) et affiche le résultat grâce à un
/// [FutureBuilder], qui gère automatiquement les trois moments d'une requête
/// asynchrone : en cours, erreur, terminée.
///
/// C'est un [StatefulWidget] pour **créer la requête une seule fois**
/// (dans `initState`) et éviter de rappeler l'API à chaque reconstruction.
class GithubReposSection extends StatefulWidget {
  const GithubReposSection({super.key, required this.username});

  final String username;

  @override
  State<GithubReposSection> createState() => _GithubReposSectionState();
}

class _GithubReposSectionState extends State<GithubReposSection> {
  final GithubService _service = GithubService();
  late Future<List<GithubRepo>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchRepos(widget.username);
  }

  @override
  void didUpdateWidget(covariant GithubReposSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le pseudo change (après édition du profil), on relance la requête.
    if (oldWidget.username != widget.username) {
      _future = _service.fetchRepos(widget.username);
    }
  }

  void _retry() {
    setState(() => _future = _service.fetchRepos(widget.username));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    return FutureBuilder<List<GithubRepo>>(
      future: _future,
      builder: (context, snapshot) {
        // 1) Requête en cours → indicateur de chargement.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2) Erreur → message clair + bouton réessayer.
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${snapshot.error}',
                style:
                    text.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _retry,
                child: Text(l.retry),
              ),
            ],
          );
        }

        // 3) Données prêtes.
        final List<GithubRepo> repos = snapshot.data ?? [];
        if (repos.isEmpty) {
          return Text(
            l.githubNoRepos,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          );
        }

        // Résumé : total d'étoiles, langage principal, dernière mise à jour.
        final int totalStars = repos.fold<int>(0, (sum, r) => sum + r.stars);
        final Map<String, int> langCounts = {};
        for (final r in repos) {
          final String? lang = r.language;
          if (lang != null) langCounts[lang] = (langCounts[lang] ?? 0) + 1;
        }
        String? topLanguage;
        int bestCount = 0;
        langCounts.forEach((lang, c) {
          if (c > bestCount) {
            bestCount = c;
            topLanguage = lang;
          }
        });
        DateTime? latest;
        for (final r in repos) {
          final DateTime? d = r.updatedAt;
          if (d != null && (latest == null || d.isAfter(latest))) latest = d;
        }
        String formatDate(DateTime d) =>
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.githubSummary(repos.length, totalStars),
                    style: text.titleMedium,
                  ),
                  if (topLanguage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l.githubMainLanguage(topLanguage!),
                      style: text.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  if (latest != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      l.githubLastUpdate(formatDate(latest)),
                      style: text.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final repo in repos) ...[
              GithubRepoCard(repo: repo),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
