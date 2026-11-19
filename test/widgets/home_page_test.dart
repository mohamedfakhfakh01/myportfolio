// Test de widget de l'écran d'accueil : liste, recherche, suppression avec
// confirmation, et les états chargement / erreur / vide.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/app/theme/theme_controller.dart';
import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/features/portfolio/presentation/pages/home_page.dart';
import 'package:myportfolio/features/portfolio/presentation/widgets/student_card.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Faux dépôt en mémoire. [failuresLeft] : nombre de chargements qui échouent
/// avant de réussir. [gate] : si fourni, le chargement attend qu'on l'ouvre
/// (pour observer l'état « chargement en cours »).
class _FakeRepo extends PortfolioRepository {
  _FakeRepo(List<Student> students, {this.failuresLeft = 0, this.gate})
      : _students = List<Student>.of(students);
  final List<Student> _students;
  int failuresLeft;
  final Completer<void>? gate;

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<void> ensureDemoStudent() async {}

  @override
  Future<List<Student>> getStudents() async {
    if (gate != null) await gate!.future;
    if (failuresLeft > 0) {
      failuresLeft--;
      throw Exception('base indisponible');
    }
    return List<Student>.of(_students);
  }

  @override
  Future<void> deleteStudent(int id) async =>
      _students.removeWhere((s) => s.id == id);
}

const Student _alice =
    Student(id: 1, fullName: 'Alice Martin', field: 'Informatique');
const Student _bob = Student(id: 2, fullName: 'Bob Durand', field: 'Génie civil');

/// Affiche l'accueil sur un écran de téléphone (360 × 800).
Future<PortfolioProvider> _pumpHome(
  WidgetTester tester,
  _FakeRepo repo, {
  Locale locale = const Locale('fr'),
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final provider = PortfolioProvider(repository: repo);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioProvider>.value(value: provider),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return provider;
}

/// Bouton « supprimer » de la carte qui porte [name].
Finder _deleteButtonOf(String name) => find.descendant(
      of: find.widgetWithText(StudentCard, name),
      matching: find.byIcon(Icons.delete_outline),
    );

void main() {
  group('Accueil', () {
    testWidgets('liste tous les portfolios', (tester) async {
      await _pumpHome(tester, _FakeRepo([_alice, _bob]));

      expect(find.text('Les portfolios'), findsOneWidget);
      expect(find.byType(StudentCard), findsNWidgets(2));
      expect(find.text('Alice Martin'), findsOneWidget);
      expect(find.text('Bob Durand'), findsOneWidget);
    });

    group('recherche', () {
      testWidgets('par nom, sans tenir compte de la casse ni des espaces',
          (tester) async {
        await _pumpHome(tester, _FakeRepo([_alice, _bob]));

        await tester.enterText(find.byType(TextField), '  ALICE ');
        await tester.pumpAndSettle();

        expect(find.text('Alice Martin'), findsOneWidget);
        expect(find.text('Bob Durand'), findsNothing);
      });

      testWidgets('par filière, accents compris', (tester) async {
        await _pumpHome(tester, _FakeRepo([_alice, _bob]));

        await tester.enterText(find.byType(TextField), 'GÉNIE');
        await tester.pumpAndSettle();

        expect(find.text('Bob Durand'), findsOneWidget);
        expect(find.text('Alice Martin'), findsNothing);
      });

      testWidgets('aucun résultat : message, puis « Effacer » réaffiche tout',
          (tester) async {
        await _pumpHome(tester, _FakeRepo([_alice, _bob]));

        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        expect(find.text('Aucun résultat pour « zzz ».'), findsOneWidget);
        expect(find.byType(StudentCard), findsNothing);

        await tester.tap(find.byTooltip('Effacer'));
        await tester.pumpAndSettle();
        expect(find.byType(StudentCard), findsNWidgets(2));
        expect(find.byTooltip('Effacer'), findsNothing);
      });
    });

    group('suppression', () {
      testWidgets('« Annuler » ne supprime rien', (tester) async {
        final provider = await _pumpHome(tester, _FakeRepo([_alice, _bob]));

        await tester.tap(_deleteButtonOf('Bob Durand'));
        await tester.pumpAndSettle();
        expect(find.text('Supprimer le portfolio ?'), findsOneWidget);

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(find.text('Bob Durand'), findsOneWidget);
        expect(provider.students, hasLength(2));
      });

      testWidgets('confirmer supprime le bon portfolio et le dit',
          (tester) async {
        final provider = await _pumpHome(tester, _FakeRepo([_alice, _bob]));

        await tester.tap(_deleteButtonOf('Bob Durand'));
        await tester.pumpAndSettle();
        // Le message nomme le portfolio concerné.
        expect(
          find.textContaining('« Bob Durand »'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
        await tester.pumpAndSettle();

        expect(find.text('Bob Durand'), findsNothing);
        expect(find.text('Alice Martin'), findsOneWidget);
        expect(provider.students.map((s) => s.id), [1]);
        expect(find.text('Portfolio supprimé'), findsOneWidget);

        // Laisse expirer la SnackBar (sinon un minuteur reste en attente).
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      });
    });

    group('navigation', () {
      testWidgets('toucher une carte ouvre son profil', (tester) async {
        await _pumpHome(tester, _FakeRepo([_alice, _bob]));

        await tester.tap(find.text('Alice Martin'));
        await tester.pumpAndSettle();

        expect(find.text('Bonjour, Alice'), findsOneWidget);
      });

      testWidgets('« Ajouter un CV » ouvre le formulaire de création',
          (tester) async {
        await _pumpHome(tester, _FakeRepo([_alice]));

        await tester.tap(find.text('Ajouter un CV'));
        await tester.pumpAndSettle();

        expect(find.text('Nouveau portfolio'), findsOneWidget);
      });
    });

    group('états', () {
      testWidgets('chargement : indicateur, puis la liste', (tester) async {
        final gate = Completer<void>();
        await _pumpHome(tester, _FakeRepo([_alice], gate: gate), settle: false);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(StudentCard), findsNothing);

        gate.complete();
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Alice Martin'), findsOneWidget);
      });

      testWidgets('vide : message humain et bouton d\'ajout disponible',
          (tester) async {
        await _pumpHome(tester, _FakeRepo([]));

        expect(find.text('Aucun portfolio'), findsOneWidget);
        expect(find.text('Ajouter un CV'), findsOneWidget);
      });

      testWidgets('erreur : message, puis « Réessayer » recharge',
          (tester) async {
        await _pumpHome(tester, _FakeRepo([_alice], failuresLeft: 1));

        expect(find.text('Impossible de charger les données.'), findsOneWidget);
        expect(find.text('Alice Martin'), findsNothing);

        await tester.tap(find.text('Réessayer'));
        await tester.pumpAndSettle();
        expect(find.text('Alice Martin'), findsOneWidget);
      });

      testWidgets('erreur en anglais : le message est traduit', (tester) async {
        await _pumpHome(
          tester,
          _FakeRepo([_alice], failuresLeft: 1),
          locale: const Locale('en'),
        );

        expect(find.text('Could not load the data.'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });
  });
}
