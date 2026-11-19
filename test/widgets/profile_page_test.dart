// Test de widget de la page profil (tableau de bord) : ce que voit le
// recruteur doit refléter exactement les données de l'étudiant.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/features/portfolio/presentation/pages/profile_page.dart';
import 'package:myportfolio/features/portfolio/presentation/widgets/profile_completion_card.dart';
import 'package:myportfolio/features/portfolio/presentation/widgets/stat_tile.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Faux dépôt en mémoire : la page ne fait que lire.
class _FakeRepo extends PortfolioRepository {
  _FakeRepo(this._students);
  final List<Student> _students;

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<List<Student>> getStudents() async => List<Student>.of(_students);
}

/// Profil partiel : bio, e-mail, 2 compétences, 2 projets, 1 expérience.
/// Pas de pseudo GitHub → aucun appel réseau pendant le test.
const Student _alice = Student(
  id: 1,
  fullName: 'Alice Martin',
  field: '2e année informatique',
  bio: 'Passionnée par le mobile.',
  email: 'alice@example.com',
  skills: [
    Skill(name: 'Flutter', level: 80, category: SkillCategory.framework),
    Skill(name: 'Dart', level: 65, category: SkillCategory.language),
  ],
  projects: [
    Project(
      id: 10,
      title: 'Appli météo',
      description: 'Prévisions locales.',
      tags: ['Flutter', 'API'],
    ),
    Project(
      id: 11,
      title: 'Site vitrine',
      description: 'Site pour un commerce.',
      tags: ['HTML'],
    ),
  ],
  experiences: [ExperienceEntry(id: 20, title: 'Stage développeur')],
);

/// Affiche la page profil sur un écran de téléphone (360 × 800 par défaut).
Future<void> _pumpProfile(
  WidgetTester tester,
  Student student, {
  Size physicalSize = const Size(1080, 2400),
}) async {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final provider = PortfolioProvider(repository: _FakeRepo([student]));
  await tester.pumpWidget(
    ChangeNotifierProvider<PortfolioProvider>.value(
      value: provider,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfilePage(studentId: student.id!),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Fait défiler jusqu'à l'élément puis le touche.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('Page profil', () {
    testWidgets('en-tête : salutation par le prénom et filière',
        (tester) async {
      await _pumpProfile(tester, _alice);

      expect(find.text('Bonjour, Alice'), findsOneWidget);
      expect(find.text('2e année informatique'), findsOneWidget);
    });

    testWidgets('complétion : 5 critères sur 11 → 45 %', (tester) async {
      await _pumpProfile(tester, _alice);

      // bio, e-mail, compétences, projets, expérience = 5 ; 5/11 = 45 %.
      expect(find.text('45%'), findsOneWidget);
      expect(find.text('5 éléments sur 11 renseignés'), findsOneWidget);
    });

    testWidgets('tuiles : nombre de compétences, projets et parcours',
        (tester) async {
      await _pumpProfile(tester, _alice);

      expect(find.widgetWithText(StatTile, 'Compétences'), findsOneWidget);
      final values = tester
          .widgetList<StatTile>(find.byType(StatTile))
          .map((t) => '${t.label}=${t.value}');
      expect(values, ['Compétences=2', 'Projets=2', 'Parcours=1']);
    });

    testWidgets('contenu : bio, contact, niveaux exacts, projets, parcours',
        (tester) async {
      await _pumpProfile(tester, _alice);

      expect(find.text('Passionnée par le mobile.'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      // Les niveaux sont affichés en pourcentage exact (pas en points).
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Appli météo'), findsOneWidget);
      expect(find.text('Site vitrine'), findsOneWidget);
      expect(find.text('Stage développeur'), findsOneWidget);
      // Pas de pseudo GitHub → pas de section dépôts (ni d'appel réseau).
      expect(find.text('Dépôts GitHub'), findsNothing);
    });

    testWidgets('toucher la carte de complétion liste les manques',
        (tester) async {
      await _pumpProfile(tester, _alice);

      await _tapVisible(tester, find.byType(ProfileCompletionCard));

      expect(find.text('À compléter pour atteindre 100 %'), findsOneWidget);
      for (final manque in [
        'Photo de profil',
        'Numéro de téléphone',
        'Profil LinkedIn',
        'Localisation',
        'Pseudo GitHub',
        'Au moins une formation',
      ]) {
        expect(find.text(manque), findsOneWidget, reason: manque);
      }
      // Ce qui est déjà rempli n'apparaît pas dans la liste.
      expect(find.text('Biographie'), findsNothing);
      expect(find.text('Adresse e-mail'), findsNothing);
    });

    // Régression : la feuille ne défilait pas et débordait quand beaucoup de
    // critères manquaient — cas d'un portfolio tout juste créé (11 sur 11).
    for (final (nom, taille) in [
      ('petit téléphone 360×800', const Size(1080, 2400)),
      ('grand téléphone 440×956', const Size(1320, 2868)),
    ]) {
      testWidgets('profil vide ($nom) : les 11 manques sont tous atteignables',
          (tester) async {
        await _pumpProfile(
          tester,
          const Student(id: 3, fullName: 'Nouveau', field: 'Info'),
          physicalSize: taille,
        );

        await _tapVisible(tester, find.byType(ProfileCompletionCard));

        // Le dernier critère doit pouvoir être amené à l'écran et touché.
        final Finder dernier = find.text('Au moins une formation');
        await tester.ensureVisible(dernier);
        await tester.pumpAndSettle();
        expect(dernier.hitTestable(), findsOneWidget);
      });
    }

    testWidgets('filtre par techno : seuls les projets concernés restent',
        (tester) async {
      await _pumpProfile(tester, _alice);

      // « HTML » existe deux fois : puce du filtre (en premier) et étiquette
      // du projet. On touche la puce du filtre.
      await _tapVisible(tester, find.text('HTML').first);
      expect(find.text('Site vitrine'), findsOneWidget);
      expect(find.text('Appli météo'), findsNothing);

      // « Tous » réaffiche l'ensemble.
      await _tapVisible(tester, find.text('Tous'));
      expect(find.text('Site vitrine'), findsOneWidget);
      expect(find.text('Appli météo'), findsOneWidget);
    });

    testWidgets('profil vide : 0 %, messages d\'état vide, pas de filtre',
        (tester) async {
      await _pumpProfile(
        tester,
        const Student(id: 2, fullName: 'Bob', field: 'Info'),
      );

      expect(find.text('Bonjour, Bob'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('0 éléments sur 11 renseignés'), findsOneWidget);
      expect(
        find.text('Aucune compétence. Appuie sur + pour en ajouter une.'),
        findsOneWidget,
      );
      expect(
        find.text('Aucun projet. Appuie sur + pour en ajouter un.'),
        findsOneWidget,
      );
      expect(
        find.text('Aucune expérience. Appuie sur + pour en ajouter.'),
        findsOneWidget,
      );
      expect(
        find.text('Aucune formation. Appuie sur + pour en ajouter.'),
        findsOneWidget,
      );
      expect(find.text('Tous'), findsNothing);
    });
  });
}
