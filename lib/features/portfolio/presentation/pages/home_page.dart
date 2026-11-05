import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/widgets/fade_slide_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/student.dart';
import '../../providers/portfolio_provider.dart';
import '../widgets/student_card.dart';
import '../widgets/student_edit_dialog.dart';
import 'profile_page.dart';

/// Écran d'**accueil** : liste les portfolios des deux étudiants du binôme.
///
/// C'est le point de départ de l'application. L'utilisateur y choisit un
/// portfolio à consulter.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Demande confirmation puis supprime le portfolio de [student].
  Future<void> _confirmDeletePortfolio(Student student) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final provider = context.read<PortfolioProvider>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.deletePortfolioTitle),
        content: Text(l.deletePortfolioBody(student.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteStudent(student.id!);
      messenger.showSnackBar(SnackBar(content: Text(l.portfolioDeleted)));
    }
  }

  /// Bouton de bascule clair/sombre, affiché dans l'AppBar.
  List<Widget> _appBarActions(BuildContext context) {
    final bool isDark = context.watch<ThemeController>().isDark;
    final AppLocalizations l = AppLocalizations.of(context);
    return [
      IconButton(
        icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
        tooltip: isDark ? l.switchToLight : l.switchToDark,
        onPressed: () => context.read<ThemeController>().toggle(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // `context.watch` écoute le PortfolioProvider : si l'état change
    // (chargement, erreur, liste), cet écran se reconstruit automatiquement.
    final provider = context.watch<PortfolioProvider>();
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    // 1) Chargement en cours : indicateur tournant.
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MyPortfolio'),
          actions: _appBarActions(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Erreur : message clair + bouton réessayer.
    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MyPortfolio'),
          actions: _appBarActions(context),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: provider.load,
                  child: Text(l.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3) Données prêtes.
    final students = provider.students;

    // Filtrage par nom ou par filière (insensible à la casse).
    final String q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? students
        : students
            .where((s) =>
                s.fullName.toLowerCase().contains(q) ||
                s.field.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      appBar: AppBar(
          title: const Text('MyPortfolio'),
          actions: _appBarActions(context),
        ),
      // Apparition en fondu au chargement (de transparent à opaque).
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) =>
            Opacity(opacity: value, child: child),
        child: students.isEmpty
            // État vide : message clair plutôt qu'un écran blanc.
            ? const _EmptyState()
            : ListView(
                // Marge basse pour dégager la nav flottante (extendBody).
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
                children: [
                  Text(l.homeHeadline, style: text.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    l.homeSubtitle,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Barre de recherche : filtre par nom ou filière.
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: l.clear,
                              onPressed: () => setState(() {
                                _searchController.clear();
                                _query = '';
                              }),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Aucun résultat pour la recherche en cours.
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        l.noResults(_query.trim()),
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    // Une carte par étudiant (filtré).
                    for (final student in filtered) ...[
                      StudentCard(
                        student: student,
                        onTap: () {
                          // Navigue vers l'écran profil en empilant une nouvelle
                          // page. `Navigator.push` ajoute ProfilePage au-dessus
                          // de l'accueil ; la flèche de retour la retire.
                          Navigator.of(context).push(
                            fadeSlideRoute(ProfilePage(studentId: student.id!)),
                          );
                        },
                        onDelete: () => _confirmDeletePortfolio(student),
                      ),
                      const SizedBox(height: 14),
                    ],
                ],
              ),
      ),
      // Remonté pour ne pas chevaucher la nav flottante (extendBody).
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 108),
        child: FloatingActionButton.extended(
          onPressed: () => showStudentEditDialog(context),
          icon: const Icon(Icons.add),
          label: Text(l.addCv),
        ),
      ),
    );
  }
}

/// Widget affiché quand il n'y a aucun étudiant (état vide).
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(l.emptyTitle, style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
              l.emptyBody,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
