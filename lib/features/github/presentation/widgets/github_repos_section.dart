import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
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
                child: const Text('Réessayer'),
              ),
            ],
          );
        }

        // 3) Données prêtes.
        final List<GithubRepo> repos = snapshot.data ?? [];
        if (repos.isEmpty) {
          return Text(
            'Aucun dépôt public trouvé.',
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          );
        }

        return Column(
          children: [
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
