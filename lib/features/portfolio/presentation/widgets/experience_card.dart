import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/experience.dart';

/// Carte d'une entrée de parcours (expérience ou formation) :
/// icône + intitulé, puis « organisation · période », puis description.
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({super.key, required this.entry, this.onTap});

  final ExperienceEntry entry;

  /// Action au toucher (ex : ouvrir la modification). Si null, non cliquable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    // Sous-titre : organisation et période, séparées par un point médian.
    final String meta = [
      if (entry.organization != null && entry.organization!.isNotEmpty)
        entry.organization!,
      if (entry.period != null && entry.period!.isNotEmpty) entry.period!,
    ].join(' · ');

    final bool hasDescription =
        entry.description != null && entry.description!.isNotEmpty;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  entry.kind == ExperienceKind.education
                      ? Icons.school_outlined
                      : Icons.work_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: text.titleMedium),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    if (hasDescription) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.description!,
                        style: text.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
