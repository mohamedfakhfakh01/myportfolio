// Tests des formulaires en feuilles remontantes : projet, compétence, parcours.
// Ce sont les endroits où l'utilisateur ÉCRIT des données : on vérifie la
// validation, ce qui est réellement enregistré, et le double appui.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/features/portfolio/presentation/widgets/experience_form_dialog.dart';
import 'package:myportfolio/features/portfolio/presentation/widgets/project_form_dialog.dart';
import 'package:myportfolio/features/portfolio/presentation/widgets/skill_form_dialog.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

import '../helpers/fake_portfolio_repository.dart';

const Skill _flutter =
    Skill(id: 50, name: 'Flutter', level: 80, category: SkillCategory.framework);

late FakePortfolioRepository _repo;

/// Écran hôte (téléphone 360 × 800) avec un bouton par formulaire.
Future<PortfolioProvider> _pumpHost(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  _repo = FakePortfolioRepository([
    const Student(id: 1, fullName: 'Alice', field: 'Info', skills: [_flutter]),
  ]);
  final provider = PortfolioProvider(repository: _repo);
  await tester.pumpWidget(
    ChangeNotifierProvider<PortfolioProvider>.value(
      value: provider,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 60),
                TextButton(
                  onPressed: () => showProjectFormDialog(context, studentId: 1),
                  child: const Text('nouveau projet'),
                ),
                TextButton(
                  onPressed: () => showSkillFormDialog(context, studentId: 1),
                  child: const Text('nouvelle compétence'),
                ),
                TextButton(
                  onPressed: () => showSkillFormDialog(
                    context,
                    studentId: 1,
                    skill: provider.studentById(1).skills.first,
                  ),
                  child: const Text('modifier compétence'),
                ),
                TextButton(
                  onPressed: () => showExperienceFormDialog(
                    context,
                    studentId: 1,
                    defaultKind: ExperienceKind.education,
                  ),
                  child: const Text('nouvelle formation'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

Future<void> _open(WidgetTester tester, String button) async {
  await tester.tap(find.text(button));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String label, String value) =>
    tester.enterText(find.widgetWithText(TextFormField, label), value);

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.text('Enregistrer'));
  await tester.pumpAndSettle();
}

/// Laisse expirer la SnackBar (sinon un minuteur reste en attente).
Future<void> _flushSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  group('Formulaire projet', () {
    testWidgets('titre et description obligatoires : rien n\'est écrit',
        (tester) async {
      await _pumpHost(tester);
      await _open(tester, 'nouveau projet');

      await _tapSave(tester);

      expect(find.text('Le titre est obligatoire'), findsOneWidget);
      expect(find.text('La description est obligatoire'), findsOneWidget);
      expect(_repo.writes, 0);
    });

    testWidgets('enregistre les données nettoyées (espaces, lien vide)',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouveau projet');

      await _type(tester, 'Titre *', '  Appli météo  ');
      await _type(tester, 'Description *', 'Prévisions.');
      await _type(tester, 'Lien (optionnel)', '   ');
      await _type(
        tester,
        'Technologies (séparées par des virgules)',
        ' Flutter , , Dart ,',
      );
      await _tapSave(tester);

      final p = provider.studentById(1).projects.single;
      expect(p.title, 'Appli météo');
      expect(p.link, isNull);
      expect(p.tags, ['Flutter', 'Dart']);
      expect(find.text('Projet enregistré'), findsOneWidget);
      await _flushSnackBar(tester);
    });

    testWidgets('technologies en double (casse ignorée) : gardées une fois',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouveau projet');

      await _type(tester, 'Titre *', 'App');
      await _type(tester, 'Description *', 'Desc.');
      await _type(
        tester,
        'Technologies (séparées par des virgules)',
        'Flutter, Dart, flutter, FLUTTER',
      );
      await _tapSave(tester);

      expect(provider.studentById(1).projects.single.tags, ['Flutter', 'Dart']);
      await _flushSnackBar(tester);
    });

    testWidgets('double appui sur « Enregistrer » : un seul projet',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouveau projet');
      await _type(tester, 'Titre *', 'App');
      await _type(tester, 'Description *', 'Desc.');

      // Deux appuis rapides, avant la fin du premier enregistrement.
      await tester.tap(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(provider.studentById(1).projects, hasLength(1));
      // Une seule fermeture : on est revenu sur l'écran hôte, pas au-delà.
      expect(find.text('nouveau projet'), findsOneWidget);
      await _flushSnackBar(tester);
    });
  });

  group('Formulaire compétence', () {
    testWidgets('niveau > 100 refusé', (tester) async {
      await _pumpHost(tester);
      await _open(tester, 'nouvelle compétence');

      await _type(tester, 'Nom *', 'Dart');
      await _type(tester, 'Niveau 0–100 (optionnel)', '150');
      await _tapSave(tester);

      expect(find.text('Entre 0 et 100'), findsOneWidget);
      expect(_repo.writes, 0);
    });

    // Le champ n'accepte que des chiffres : lettres et signe « - » ne peuvent
    // même pas être saisis (filtre du clavier), donc pas de niveau négatif.
    for (final (saisie, reste) in [('abc', ''), ('-5', '5'), ('8a0', '80')]) {
      testWidgets('niveau : « $saisie » est filtré en « $reste »',
          (tester) async {
        await _pumpHost(tester);
        await _open(tester, 'nouvelle compétence');

        await _type(tester, 'Niveau 0–100 (optionnel)', saisie);
        await tester.pump();

        final field = tester.widget<EditableText>(find.descendant(
          of: find.widgetWithText(TextFormField, 'Niveau 0–100 (optionnel)'),
          matching: find.byType(EditableText),
        ));
        expect(field.controller.text, reste);
      });
    }

    testWidgets('niveau vide accepté (non renseigné, rien d\'inventé)',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouvelle compétence');

      await _type(tester, 'Nom *', ' Dart ');
      await _tapSave(tester);

      final dart = provider.studentById(1).skills.last;
      expect(dart.name, 'Dart');
      expect(dart.level, isNull);
      await _flushSnackBar(tester);
    });

    testWidgets('modifier : prérempli, puis niveau mis à jour', (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'modifier compétence');

      expect(find.text('Modifier la compétence'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Flutter'), findsOneWidget);
      await _type(tester, 'Niveau 0–100 (optionnel)', ' 90 ');
      await _tapSave(tester);

      expect(provider.studentById(1).skills.single.level, 90);
      await _flushSnackBar(tester);
    });

    testWidgets('supprimer demande confirmation', (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'modifier compétence');

      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer la compétence ?'), findsOneWidget);
      await tester.tap(find.text('Annuler').last);
      await tester.pumpAndSettle();
      expect(provider.studentById(1).skills, hasLength(1));

      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Supprimer').last);
      await tester.pumpAndSettle();
      expect(provider.studentById(1).skills, isEmpty);
      await _flushSnackBar(tester);
    });

    testWidgets('double appui sur « Enregistrer » : une seule compétence',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouvelle compétence');
      await _type(tester, 'Nom *', 'Dart');

      await tester.tap(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(provider.studentById(1).skills, hasLength(2)); // Flutter + Dart
      expect(find.text('nouvelle compétence'), findsOneWidget);
      await _flushSnackBar(tester);
    });
  });

  group('Formulaire parcours', () {
    testWidgets('intitulé obligatoire', (tester) async {
      await _pumpHost(tester);
      await _open(tester, 'nouvelle formation');

      await _tapSave(tester);

      expect(find.text('Le titre est obligatoire'), findsOneWidget);
      expect(_repo.writes, 0);
    });

    testWidgets('ouvert depuis « Formation » : enregistré comme formation',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouvelle formation');

      await _type(tester, 'Titre *', 'Licence Informatique');
      await _type(tester, 'Organisation / établissement', 'IIT Sfax');
      await _tapSave(tester);

      final e = provider.studentById(1).experiences.single;
      expect(e.title, 'Licence Informatique');
      expect(e.organization, 'IIT Sfax');
      expect(e.kind, ExperienceKind.education);
      await _flushSnackBar(tester);
    });

    testWidgets('double appui sur « Enregistrer » : une seule entrée',
        (tester) async {
      final provider = await _pumpHost(tester);
      await _open(tester, 'nouvelle formation');
      await _type(tester, 'Titre *', 'Licence');

      await tester.tap(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(provider.studentById(1).experiences, hasLength(1));
      expect(find.text('nouvelle formation'), findsOneWidget);
      await _flushSnackBar(tester);
    });
  });
}
