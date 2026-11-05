// Test de widget : ProjectCard (carte projet enrichie du design).
//
// On vérifie l'affichage des technologies (chips) et la présence/absence du
// bouton de lien selon que le projet a un lien ou non.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/portfolio/presentation/widgets/project_card.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/project.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('affiche le titre et les technologies en chips', (tester) async {
    await tester.pumpWidget(_wrap(
      const ProjectCard(
        project: Project(
          title: 'Mon Projet',
          description: 'Une description',
          tags: ['Flutter', 'Dart'],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mon Projet'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
  });

  testWidgets('affiche le bouton de lien quand un lien est présent',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ProjectCard(
        project: Project(
          title: 'Avec lien',
          description: 'D',
          link: 'https://example.com',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
  });

  testWidgets('pas de bouton de lien quand il n\'y a pas de lien',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ProjectCard(
        project: Project(title: 'Sans lien', description: 'D'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.open_in_new), findsNothing);
  });

  testWidgets('déclenche onTap au toucher de la carte', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(_wrap(
      ProjectCard(
        project: const Project(title: 'Tap', description: 'D'),
        onTap: () => tapped = true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tap'));
    expect(tapped, isTrue);
  });
}
