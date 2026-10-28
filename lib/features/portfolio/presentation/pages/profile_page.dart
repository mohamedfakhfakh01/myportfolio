import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../github/presentation/widgets/github_repos_section.dart';
import '../../providers/portfolio_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/skill_chip.dart';
import '../widgets/skill_form_dialog.dart';
import '../widgets/student_avatar.dart';
import '../widgets/student_edit_dialog.dart';

/// Écran **profil** : affiche (et permet de modifier) le portfolio d'un étudiant.
///
/// Reçoit l'**identifiant** de l'étudiant (pas l'objet) et lit la version à jour
/// depuis le [PortfolioProvider]. Ainsi, après un ajout/suppression, l'écran se
/// rafraîchit automatiquement.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    // On écoute le provider : l'étudiant est toujours à jour.
    final student = context.watch<PortfolioProvider>().studentById(studentId);

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier le profil',
            onPressed: () => showStudentEditDialog(context, student: student),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- En-tête : bandeau dégradé avec avatar + nom + filière ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar animé (Hero) : même tag que sur la carte d'accueil.
                  StudentAvatar(
                    heroTag: 'avatar-${student.id}',
                    initials: student.initials,
                    photoPath: student.photoPath,
                    radius: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.fullName,
                    textAlign: TextAlign.center,
                    style: text.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.field,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // --- Contenu (bio, compétences, projets, GitHub) ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Bio ---
                  if (student.bio.isNotEmpty) ...[
                    Text('À propos', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(student.bio, style: text.bodyMedium),
                    const SizedBox(height: 24),
                  ],

                  // --- Compétences (avec bouton d'ajout) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Compétences', style: text.titleMedium),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Ajouter une compétence',
                        onPressed: () =>
                            showSkillFormDialog(context, studentId: studentId),
                      ),
                    ],
                  ),
                  if (student.skills.isEmpty)
                    Text(
                      'Aucune compétence. Appuie sur + pour en ajouter une.',
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else ...[
                    Text(
                      'Touche une compétence pour la modifier.',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in student.skills)
                          SkillChip(
                            skill: skill,
                            onTap: () => showSkillFormDialog(
                              context,
                              studentId: studentId,
                              skill: skill,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // --- Projets (avec bouton d'ajout) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Projets', style: text.titleMedium),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Ajouter un projet',
                        onPressed: () => showProjectFormDialog(
                          context,
                          studentId: studentId,
                        ),
                      ),
                    ],
                  ),
                  if (student.projects.isEmpty)
                    Text(
                      'Aucun projet. Appuie sur + pour en ajouter un.',
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else ...[
                    Text(
                      'Touche un projet pour le modifier.',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final project in student.projects) ...[
                      ProjectCard(
                        project: project,
                        onTap: () => showProjectFormDialog(
                          context,
                          studentId: studentId,
                          project: project,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],

                  // --- Dépôts GitHub (si un pseudo est renseigné) ---
                  if (student.githubUsername != null) ...[
                    const SizedBox(height: 24),
                    Text('Dépôts GitHub', style: text.titleMedium),
                    const SizedBox(height: 12),
                    GithubReposSection(username: student.githubUsername!),
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
