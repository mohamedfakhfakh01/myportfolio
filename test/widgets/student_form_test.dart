// Test de widget du formulaire « Ajouter un CV » / modification du profil :
// il ne doit jamais permettre de créer (ou renommer vers) un nom déjà pris.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/features/portfolio/presentation/pages/student_form_page.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Faux dépôt en mémoire : juste ce dont le formulaire a besoin.
class _FakeRepo extends PortfolioRepository {
  _FakeRepo(List<Student> students) : _students = List<Student>.of(students);
  final List<Student> _students;
  int _nextId = 100;

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<List<Student>> getStudents() async => List<Student>.of(_students);

  @override
  Future<int> insertStudent(Student student) async {
    // Une vraie base prend un peu de temps : permet de reproduire un double
    // appui pendant l'enregistrement.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final int id = _nextId++;
    _students.add(student.copyWith(
      id: id,
      skills: const [],
      projects: const [],
      experiences: const [],
    ));
    return id;
  }

  @override
  Future<void> updateStudent(Student student) async {
    final int i = _students.indexWhere((s) => s.id == student.id);
    _students[i] =
        _students[i].copyWith(fullName: student.fullName, field: student.field);
  }
}

const String _nameLabel = 'Nom complet *';
const String _fieldLabel = 'Filière / niveau *';
const String _duplicateError = 'Un portfolio porte déjà ce nom.';

/// Ouvre le formulaire (création si [student] est null) au-dessus d'un écran
/// d'accueil, pour que la fermeture de la page après enregistrement soit propre.
Future<void> _openForm(
  WidgetTester tester,
  PortfolioProvider provider, {
  Student? student,
}) async {
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
                    builder: (_) => StudentFormPage(student: student),
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
}

/// Remplit le nom et la filière puis appuie sur le bouton de validation.
Future<void> _submit(
  WidgetTester tester, {
  required String name,
  required String buttonLabel,
}) async {
  await tester.enterText(find.widgetWithText(TextFormField, _nameLabel), name);
  await tester.enterText(
    find.widgetWithText(TextFormField, _fieldLabel),
    'Informatique',
  );
  // Ferme le clavier, comme un vrai utilisateur : un champ qui garde le focus
  // ramène la vue vers lui et annulerait le défilement vers le bouton.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  // Le formulaire construit tous ses champs (et non à la demande) : le bouton
  // existe déjà, il faut seulement le faire défiler jusqu'à l'écran.
  final Finder button = find.text(buttonLabel);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  PortfolioProvider makeProvider() => PortfolioProvider(
        repository: _FakeRepo([
          const Student(id: 1, fullName: 'Alice Martin', field: 'Info'),
        ]),
      );

  testWidgets('création avec un nom déjà pris : erreur, rien n\'est créé',
      (tester) async {
    final provider = makeProvider();
    await _openForm(tester, provider);

    // Casse et espaces différents : c'est quand même le même nom.
    await _submit(
      tester,
      name: '  alice   MARTIN ',
      buttonLabel: 'Créer le portfolio',
    );

    // L'erreur s'affiche SOUS LE CHAMP (validation du formulaire), et non
    // dans une SnackBar (qui signifierait que seul le provider a bloqué).
    expect(find.text(_duplicateError), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(provider.students, hasLength(1));
  });

  testWidgets(
      'régression : nom vide refusé même après défilement jusqu\'au bouton',
      (tester) async {
    // Avec l'ancienne ListView, le champ Nom était détruit hors écran, donc
    // jamais validé : on pouvait créer un portfolio sans nom.
    final provider = makeProvider();
    await _openForm(tester, provider);

    await _submit(tester, name: '', buttonLabel: 'Créer le portfolio');

    expect(find.text('Le nom est obligatoire'), findsOneWidget);
    expect(provider.students, hasLength(1));
    expect(provider.students.any((s) => s.fullName.trim().isEmpty), isFalse);
  });

  testWidgets('création avec un nom libre : portfolio créé', (tester) async {
    final provider = makeProvider();
    await _openForm(tester, provider);

    await _submit(tester, name: 'Bob Durand', buttonLabel: 'Créer le portfolio');

    expect(find.text(_duplicateError), findsNothing);
    expect(provider.students.map((s) => s.fullName),
        containsAll(['Alice Martin', 'Bob Durand']));
    // Laisse expirer le message de confirmation (sinon minuteur en attente).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('modification en gardant son propre nom : accepté',
      (tester) async {
    final provider = makeProvider();
    await _openForm(
      tester,
      provider,
      student: const Student(id: 1, fullName: 'Alice Martin', field: 'Info'),
    );

    await _submit(tester, name: 'Alice Martin', buttonLabel: 'Enregistrer');

    expect(find.text(_duplicateError), findsNothing);
    expect(provider.students.single.field, 'Informatique');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('double appui sur « Créer le portfolio » : un seul portfolio',
      (tester) async {
    final provider = makeProvider();
    await _openForm(tester, provider);

    await tester.enterText(
        find.widgetWithText(TextFormField, _nameLabel), 'Carla Petit');
    await tester.enterText(
        find.widgetWithText(TextFormField, _fieldLabel), 'Informatique');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final Finder button = find.text('Créer le portfolio');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    // Deux appuis rapides, avant la fin du premier enregistrement.
    await tester.tap(button);
    await tester.tap(button, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(
      provider.students.where((s) => s.fullName == 'Carla Petit'),
      hasLength(1),
    );
    // Une seule fermeture : retour à l'écran de départ, pas au-delà.
    expect(find.text('ouvrir'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
