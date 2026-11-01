import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../services/portfolio_pdf.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/skill.dart';
import '../../../github/presentation/widgets/github_repos_section.dart';
import '../../providers/portfolio_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';
import '../widgets/skill_category_label.dart';
import '../widgets/skill_level_tile.dart';
import '../widgets/stat_tile.dart';
import '../widgets/skill_form_dialog.dart';
import '../widgets/student_avatar.dart';
import '../widgets/student_edit_dialog.dart';

/// Écran **profil** : affiche (et permet de modifier) le portfolio d'un étudiant.
///
/// Reçoit l'**identifiant** de l'étudiant (pas l'objet) et lit la version à jour
/// depuis le [PortfolioProvider]. Ainsi, après un ajout/suppression, l'écran se
/// rafraîchit automatiquement.
/// Critères de tri des compétences.
enum _SkillSort { name, level }

/// Critères de tri des projets.
enum _ProjectSort { titleAsc, titleDesc }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.studentId});

  final int studentId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _SkillSort _skillSort = _SkillSort.name;
  _ProjectSort _projectSort = _ProjectSort.titleAsc;

  @override
  Widget build(BuildContext context) {
    final int studentId = widget.studentId;
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    // On écoute le provider : l'étudiant est toujours à jour.
    final student = context.watch<PortfolioProvider>().studentById(studentId);

    // Listes triées selon le critère choisi (on copie pour ne pas modifier
    // l'original).
    final skills = [...student.skills];
    switch (_skillSort) {
      case _SkillSort.name:
        skills.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case _SkillSort.level:
        skills.sort((a, b) => (b.level ?? -1).compareTo(a.level ?? -1));
    }
    final projects = [...student.projects];
    switch (_projectSort) {
      case _ProjectSort.titleAsc:
        projects.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _ProjectSort.titleDesc:
        projects.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l.exportPdf,
            onPressed: () async {
              // On capture le messenger AVANT l'await (bonne pratique : ne pas
              // réutiliser `context` après une opération asynchrone).
              final messenger = ScaffoldMessenger.of(context);
              try {
                final bytes = await buildPortfolioPdf(student, l);
                await Printing.sharePdf(
                  bytes: bytes,
                  filename:
                      'portfolio_${student.fullName.replaceAll(' ', '_')}.pdf',
                );
              } catch (_) {
                messenger.showSnackBar(SnackBar(content: Text(l.pdfError)));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.editProfile,
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
                  // --- Statistiques (compétences, projets) ---
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          label: l.skills,
                          value: '${student.skills.length}',
                          icon: Icons.star_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          label: l.projects,
                          value: '${student.projects.length}',
                          icon: Icons.folder_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Bio ---
                  if (student.bio.isNotEmpty) ...[
                    Text(l.navAbout, style: text.titleMedium),
                    const SizedBox(height: 8),
                    Text(student.bio, style: text.bodyMedium),
                    const SizedBox(height: 24),
                  ],

                  // --- Compétences (avec bouton d'ajout) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.skills, style: text.titleMedium),
                      Row(
                        children: [
                          PopupMenuButton<_SkillSort>(
                            icon: const Icon(Icons.sort),
                            tooltip: l.sortSkills,
                            initialValue: _skillSort,
                            onSelected: (s) => setState(() => _skillSort = s),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: _SkillSort.name,
                                child: Text(l.sortByNameAsc),
                              ),
                              PopupMenuItem(
                                value: _SkillSort.level,
                                child: Text(l.sortByLevelDesc),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                            ),
                            tooltip: l.addSkill,
                            onPressed: () => showSkillFormDialog(
                              context,
                              studentId: studentId,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (student.skills.isEmpty)
                    Text(
                      l.skillsEmpty,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else ...[
                    Text(
                      l.skillsHint,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Regroupées par catégorie (Langages, Frameworks…), triées
                    // à l'intérieur de chaque groupe selon le critère choisi.
                    for (final category in SkillCategory.values)
                      if (skills.any((s) => s.category == category)) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 2),
                          child: Text(
                            skillCategoryLabel(l, category),
                            style: text.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        for (final skill
                            in skills.where((s) => s.category == category))
                          SkillLevelTile(
                            skill: skill,
                            onTap: () => showSkillFormDialog(
                              context,
                              studentId: studentId,
                              skill: skill,
                            ),
                          ),
                      ],
                  ],
                  const SizedBox(height: 24),

                  // --- Projets (avec bouton d'ajout) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.projects, style: text.titleMedium),
                      Row(
                        children: [
                          PopupMenuButton<_ProjectSort>(
                            icon: const Icon(Icons.sort),
                            tooltip: l.sortProjects,
                            initialValue: _projectSort,
                            onSelected: (s) => setState(() => _projectSort = s),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: _ProjectSort.titleAsc,
                                child: Text(l.sortByTitleAsc),
                              ),
                              PopupMenuItem(
                                value: _ProjectSort.titleDesc,
                                child: Text(l.sortByTitleDesc),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                            ),
                            tooltip: l.addProject,
                            onPressed: () => showProjectFormDialog(
                              context,
                              studentId: studentId,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (student.projects.isEmpty)
                    Text(
                      l.projectsEmpty,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else ...[
                    Text(
                      l.projectsHint,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final project in projects) ...[
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
                    Text(l.githubRepos, style: text.titleMedium),
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
