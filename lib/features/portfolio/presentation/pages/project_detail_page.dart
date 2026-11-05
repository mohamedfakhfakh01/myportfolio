import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/widgets/pill_tag.dart';
import '../../providers/portfolio_provider.dart';
import '../widgets/project_form_dialog.dart';

/// Écran **détail d'un projet** (« case study » du design) : grande image,
/// titre, technologies, description complète et lien.
///
/// Reçoit les **identifiants** (étudiant + projet) et lit la version à jour
/// depuis le [PortfolioProvider] : après une modification, l'écran se rafraîchit
/// tout seul ; après une suppression, il se referme.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({
    super.key,
    required this.studentId,
    required this.projectId,
  });

  final int studentId;
  final int projectId;

  Future<void> _openLink(BuildContext context, String link) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    String raw = link.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'https://$raw';
    }
    final Uri? uri = Uri.tryParse(raw);
    final bool ok = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.linkError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    final provider = context.watch<PortfolioProvider>();
    final student = provider.studentById(studentId);

    // On retrouve le projet par son identifiant (à jour après édition).
    Project? project;
    for (final p in student.projects) {
      if (p.id == projectId) {
        project = p;
        break;
      }
    }

    // Projet supprimé : on referme l'écran après la frame courante.
    if (project == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final Project p = project;
    final bool hasImage =
        p.imagePath != null && File(p.imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.projectEditTitle,
            onPressed: () => showProjectFormDialog(
              context,
              studentId: studentId,
              project: p,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (hasImage)
            Image.file(
              File(p.imagePath!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: text.headlineSmall),
                if (p.tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in p.tags)
                        PillTag(label: tag, color: AppColors.textSecondary),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  p.description,
                  style: text.bodyLarge?.copyWith(height: 1.5),
                ),
                if (p.link != null) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => _openLink(context, p.link!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                l.viewProject,
                                style: text.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
