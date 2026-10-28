import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_route.dart';
import '../../providers/portfolio_provider.dart';
import '../widgets/student_card.dart';
import '../widgets/student_edit_dialog.dart';
import 'profile_page.dart';

/// Écran d'**accueil** : liste les portfolios des deux étudiants du binôme.
///
/// C'est le point de départ de l'application. L'utilisateur y choisit un
/// portfolio à consulter.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // `context.watch` écoute le PortfolioProvider : si l'état change
    // (chargement, erreur, liste), cet écran se reconstruit automatiquement.
    final provider = context.watch<PortfolioProvider>();
    final TextTheme text = Theme.of(context).textTheme;

    // 1) Chargement en cours : indicateur tournant.
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('MyPortfolio')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Erreur : message clair + bouton réessayer.
    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('MyPortfolio')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: provider.load,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3) Données prêtes.
    final students = provider.students;

    return Scaffold(
      appBar: AppBar(title: const Text('MyPortfolio')),
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
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Les portfolios', style: text.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Choisis un étudiant pour voir son portfolio',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Une carte par étudiant.
                  for (final student in students) ...[
                    StudentCard(
                      student: student,
                      onTap: () {
                        // Navigue vers l'écran profil en empilant une nouvelle
                        // page. `Navigator.push` ajoute ProfilePage au-dessus de
                        // l'accueil ; la flèche de retour de l'AppBar la retire.
                        Navigator.of(context).push(
                          fadeSlideRoute(ProfilePage(studentId: student.id!)),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showStudentEditDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un CV'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('Aucun portfolio', style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Les portfolios des deux étudiants apparaîtront ici.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
