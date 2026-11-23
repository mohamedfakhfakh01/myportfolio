// Routes nommées (lib/app/app_routes.dart) : chaque adresse ouvre le bon
// écran, avec son nom ; une adresse inconnue ou un argument manquant mène à
// « Page introuvable » au lieu de faire planter l'application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/app/app_routes.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/student.dart';

import 'helpers/fake_portfolio_repository.dart';

const Student _alice = Student(
  id: 1,
  fullName: 'Alice Martin',
  field: 'Informatique',
  projects: [Project(id: 10, title: 'Appli météo', description: 'D.')],
);

final GlobalKey<NavigatorState> _nav = GlobalKey<NavigatorState>();

/// Monte l'app de test avec les MÊMES routes que la vraie app.
Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ChangeNotifierProvider<PortfolioProvider>.value(
    value: PortfolioProvider(repository: FakePortfolioRepository([_alice])),
    child: MaterialApp(
      navigatorKey: _nav,
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('départ')),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    ),
  ));
  await tester.pumpAndSettle();
}

/// Va à [name] et renvoie le nom de la route affichée.
Future<String?> _go(WidgetTester tester, String name, [Object? args]) async {
  _nav.currentState!.pushNamed(name, arguments: args);
  await tester.pumpAndSettle();
  return ModalRoute.of(tester.element(find.byType(Scaffold).last))
      ?.settings
      .name;
}

void main() {
  testWidgets('/profil + id : ouvre le profil de ce portfolio', (tester) async {
    await _pump(tester);
    expect(await _go(tester, AppRoutes.profil, 1), '/profil');
    expect(find.text('Bonjour, Alice'), findsOneWidget);
  });

  testWidgets('/projet + ProjectRouteArgs : ouvre le détail', (tester) async {
    await _pump(tester);
    await _go(tester, AppRoutes.projet,
        const ProjectRouteArgs(studentId: 1, projectId: 10));
    expect(find.text('Appli météo'), findsWidgets);
  });

  testWidgets('/portfolio/nouveau : formulaire de création', (tester) async {
    await _pump(tester);
    expect(await _go(tester, AppRoutes.nouveauPortfolio),
        '/portfolio/nouveau');
    expect(find.text('Nouveau portfolio'), findsOneWidget);
  });

  testWidgets('/portfolio/modifier + Student : formulaire prérempli',
      (tester) async {
    await _pump(tester);
    await _go(tester, AppRoutes.modifierPortfolio, _alice);
    expect(find.text('Modifier le profil'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Alice Martin'), findsOneWidget);
  });

  testWidgets('« Retour » ramène à l\'écran précédent', (tester) async {
    await _pump(tester);
    await _go(tester, AppRoutes.profil, 1);
    _nav.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('départ'), findsOneWidget);
  });

  group('jamais de plantage', () {
    testWidgets('adresse inconnue → « Page introuvable »', (tester) async {
      await _pump(tester);
      await _go(tester, '/n-existe-pas');
      expect(find.text('Page introuvable'), findsOneWidget);
    });

    testWidgets('mauvais argument (texte au lieu d\'un id) → introuvable',
        (tester) async {
      await _pump(tester);
      await _go(tester, AppRoutes.profil, 'pas un id');
      expect(find.text('Page introuvable'), findsOneWidget);
    });

    testWidgets('argument manquant pour /projet → introuvable',
        (tester) async {
      await _pump(tester);
      await _go(tester, AppRoutes.projet);
      expect(find.text('Page introuvable'), findsOneWidget);
    });
  });
}
