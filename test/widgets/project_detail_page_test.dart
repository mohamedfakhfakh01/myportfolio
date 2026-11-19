// Test de widget de l'écran « détail d'un projet » : affichage, modification
// (l'écran se met à jour) et suppression (l'écran se referme).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/features/portfolio/presentation/pages/project_detail_page.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/student.dart';
import 'package:myportfolio/shared/widgets/pill_tag.dart';

import '../helpers/fake_portfolio_repository.dart';

const Project _meteo = Project(
  id: 10,
  title: 'Appli météo',
  description: 'Prévisions locales sur 7 jours.',
  link: 'github.com/alice/meteo',
  tags: ['Flutter', 'API'],
);
const Project _minimal =
    Project(id: 11, title: 'Projet simple', description: 'Sans lien.');

/// Ouvre le détail du projet [projectId] au-dessus d'un écran d'accueil, pour
/// pouvoir vérifier sa fermeture.
Future<PortfolioProvider> _openDetail(WidgetTester tester, int projectId) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final provider = PortfolioProvider(
    repository: FakePortfolioRepository([
      const Student(
        id: 1,
        fullName: 'Alice Martin',
        field: 'Info',
        projects: [_meteo, _minimal],
      ),
    ]),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<PortfolioProvider>.value(
      value: provider,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ProjectDetailPage(studentId: 1, projectId: projectId),
                  ),
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  return provider;
}

/// Laisse expirer la SnackBar (sinon un minuteur reste en attente).
Future<void> _flushSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  group('Détail projet', () {
    testWidgets('affiche titre, technologies, description et lien',
        (tester) async {
      await _openDetail(tester, 10);

      // Titre dans la barre et en en-tête.
      expect(find.text('Appli météo'), findsNWidgets(2));
      expect(find.widgetWithText(PillTag, 'Flutter'), findsOneWidget);
      expect(find.widgetWithText(PillTag, 'API'), findsOneWidget);
      expect(find.text('Prévisions locales sur 7 jours.'), findsOneWidget);
      expect(find.text('Voir le projet'), findsOneWidget);
    });

    testWidgets('sans lien ni technologies : ni bouton ni puces',
        (tester) async {
      await _openDetail(tester, 11);

      expect(find.text('Projet simple'), findsNWidgets(2));
      expect(find.text('Voir le projet'), findsNothing);
      expect(find.byType(PillTag), findsNothing);
    });

    testWidgets('modifier : formulaire prérempli, écran mis à jour',
        (tester) async {
      await _openDetail(tester, 10);

      await tester.tap(find.byTooltip('Modifier le projet'));
      await tester.pumpAndSettle();
      // Les technologies sont reproposées sous forme de texte.
      expect(find.text('Flutter, API'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Appli météo'),
        'Appli météo v2',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(find.text('Appli météo v2'), findsNWidgets(2));
      expect(find.text('Projet enregistré'), findsOneWidget);
      await _flushSnackBar(tester);
    });

    testWidgets('supprimer (confirmé) : l\'écran se referme', (tester) async {
      final provider = await _openDetail(tester, 10);

      await tester.tap(find.byTooltip('Modifier le projet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer le projet ?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Supprimer').last);
      await tester.pumpAndSettle();

      // Retour à l'écran de départ, le projet n'existe plus.
      expect(find.text('ouvrir'), findsOneWidget);
      expect(provider.studentById(1).projects.map((p) => p.id), [11]);
      await _flushSnackBar(tester);
    });
  });
}
