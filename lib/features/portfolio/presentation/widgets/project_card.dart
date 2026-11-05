import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/project.dart';

/// Carte réutilisable affichant un projet (titre, description, lien éventuel).
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;

  /// Action au toucher (ex : ouvrir la modification). Si null, non cliquable.
  final VoidCallback? onTap;

  /// Ouvre le lien du projet dans le navigateur. Normalise l'URL (ajoute
  /// `https://` si le schéma manque) et prévient si l'ouverture échoue.
  Future<void> _openLink(BuildContext context, String link) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    String raw = link.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'https://$raw';
    }
    final Uri? uri = Uri.tryParse(raw);

    bool ok = false;
    if (uri != null) {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.linkError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    final bool hasImage =
        project.imagePath != null && File(project.imagePath!).existsSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImage)
              Image.file(
                File(project.imagePath!),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône dans un carré indigo clair.
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: text.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          project.description,
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Lien cliquable, affiché seulement s'il existe : un tap
                        // ouvre le projet dans le navigateur (sans déclencher le
                        // tap de la carte qui, lui, ouvre la modification).
                        if (project.link != null) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _openLink(context, project.link!),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      l.viewProject,
                                      style: text.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
