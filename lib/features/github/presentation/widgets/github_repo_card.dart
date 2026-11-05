import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/pill_tag.dart';
import '../../data/github_repo.dart';

/// Carte affichant un dépôt GitHub (nom, description, langage, étoiles).
class GithubRepoCard extends StatelessWidget {
  const GithubRepoCard({super.key, required this.repo});

  final GithubRepo repo;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(repo.name, style: text.titleMedium)),
              ],
            ),
            if (repo.description != null && repo.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                repo.description!,
                style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (repo.language != null) ...[
                  PillTag(
                    label: repo.language!,
                    icon: Icons.circle,
                  ),
                  const SizedBox(width: 12),
                ],
                Icon(Icons.star_border,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${repo.stars}', style: text.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
