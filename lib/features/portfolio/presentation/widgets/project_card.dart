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
            // --- Bandeau image (média plein cadre, coins arrondis par la carte) ---
            if (hasImage)
              Image.file(
                File(project.imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête : sans image on garde la pastille dossier comme
                  // ancrage visuel ; avec image, le titre prend toute la largeur.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!hasImage) ...[
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
                      ],
                      Expanded(
                        child: Text(project.title, style: text.titleLarge),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Lien en bouton pilule (comme les boutons d'action du design).
                  // Un tap ouvre le projet sans déclencher le tap de la carte
                  // (qui, lui, ouvre la modification).
                  if (project.link != null) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _LinkButton(
                        label: l.viewProject,
                        onTap: () => _openLink(context, project.link!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton **pilule** plein (bleu) pour ouvrir le lien d'un projet.
class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.open_in_new, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: text.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
