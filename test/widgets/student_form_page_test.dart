// Tests du formulaire « Ajouter un CV » / « Modifier le profil » : ce qui est
// saisi doit être exactement ce qui est enregistré (contenu compris), et rien
// d'autre. (Les tests anti-doublon de nom sont dans student_form_test.dart.)

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/features/github/data/github_service.dart';

import 'package:myportfolio/features/portfolio/presentation/widgets/student_edit_dialog.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

import '../helpers/fake_portfolio_repository.dart';

const Student _alice = Student(
  id: 1,
  fullName: 'Alice Martin',
  field: 'Informatique',
  bio: 'Bio d\'Alice.',
  email: 'alice@example.com',
  phone: '+216 11 222 333',
  githubUsername: 'alice',
  skills: [Skill(id: 5, name: 'Dart', level: 70)],
  projects: [Project(id: 6, title: 'Appli', description: 'D.')],
  experiences: [ExperienceEntry(id: 7, title: 'Stage')],
);

late FakePortfolioRepository _repo;

/// Adresses demandées au faux GitHub pendant le test.
late List<Uri> _githubCalls;

/// Ouvre le formulaire (création si [student] est null) sur un téléphone
/// 360 × 800, au-dessus d'un écran de départ.
///
/// GitHub est simulé : [githubStatus] est le code renvoyé (200 = le compte
/// existe, 404 = inconnu) ; [githubOffline] simule l'absence de réseau ;
/// [repos] donne, par pseudo, les noms de ses dépôts publics.
Future<PortfolioProvider> _openForm(
  WidgetTester tester, {
  Student? student,
  int githubStatus = 200,
  bool githubOffline = false,
  Map<String, List<String>> repos = const {},
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  _repo = FakePortfolioRepository([_alice]);
  _githubCalls = [];
  final github = GithubService(
    client: MockClient((request) async {
      _githubCalls.add(request.url);
      // Comme une vraie requête, la réponse prend un peu de temps.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (githubOffline) throw Exception('pas de réseau');
      final List<String> segments = request.url.pathSegments; // users/<p>/…
      if (githubStatus == 200 && segments.last == 'repos') {
        final names = repos[segments[1]] ?? const <String>[];
        return http.Response(
          jsonEncode([
            for (final n in names)
              {'name': n, 'html_url': 'https://github.com/x/$n', 'language': 'Dart'},
          ]),
          200,
        );
      }
      return http.Response('{}', githubStatus);
    }),
  );
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
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        StudentFormPage(student: student, githubService: github),
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

/// Amène [finder] à l'écran. On retire d'abord le focus : un champ actif
/// ramènerait la vue vers lui (piège n°12).
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, String label, String value) async {
  final Finder field = find.widgetWithText(TextFormField, label);
  await _reveal(tester, field);
  await tester.enterText(field, value);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Laisse expirer la SnackBar (sinon un minuteur reste en attente).
Future<void> _flushSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Student _created(PortfolioProvider p, String name) =>
    p.students.singleWhere((s) => s.fullName == name);

void main() {
  group('Création d\'un CV', () {
    testWidgets('tout ce qui est saisi est enregistré, contenu compris',
        (tester) async {
      final provider = await _openForm(tester);

      await _fill(tester, 'Nom complet *', '  Carla Petit ');
      await _fill(tester, 'Filière / niveau *', 'Génie logiciel');
      await _fill(tester, 'Bio (optionnel)', 'Passionnée.');
      await _fill(tester, 'E-mail (optionnel)', ' carla@example.com ');
      await _fill(tester, 'Localisation (optionnel)', 'Sfax');

      // Une compétence, via sa feuille.
      await _tap(tester, find.byTooltip('Ajouter une compétence'));
      await tester.enterText(find.widgetWithText(TextFormField, 'Nom *'), 'Flutter');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Niveau 0–100 (optionnel)'), '75');
      await _tap(tester, find.text('Ajouter'));
      expect(find.text('Flutter'), findsOneWidget);

      // Un projet, avec des technologies (doublon fusionné).
      await _tap(tester, find.byTooltip('Ajouter un projet'));
      await tester.enterText(find.widgetWithText(TextFormField, 'Titre *'), 'Blog');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Description *'), 'Un blog.');
      await tester.enterText(
          find.widgetWithText(
              TextFormField, 'Technologies (séparées par des virgules)'),
          'Laravel, laravel, PHP');
      await _tap(tester, find.text('Ajouter'));

      // Une expérience et une formation.
      await _tap(tester, find.byTooltip('Ajouter une expérience'));
      await tester.enterText(find.widgetWithText(TextFormField, 'Titre *'), 'Stage');
      await _tap(tester, find.text('Ajouter'));
      await _tap(tester, find.byTooltip('Ajouter une formation'));
      await tester.enterText(find.widgetWithText(TextFormField, 'Titre *'), 'Licence');
      await _tap(tester, find.text('Ajouter'));

      await _tap(tester, find.text('Créer le portfolio'));

      final Student carla = _created(provider, 'Carla Petit');
      expect(carla.field, 'Génie logiciel');
      expect(carla.bio, 'Passionnée.');
      expect(carla.email, 'carla@example.com');
      expect(carla.location, 'Sfax');
      // Champs laissés vides → non renseignés (rien d'inventé).
      expect(carla.phone, isNull);
      expect(carla.linkedin, isNull);
      expect(carla.githubUsername, isNull);
      expect(carla.skills.map((s) => '${s.name}:${s.level}'), ['Flutter:75']);
      expect(carla.projects.single.tags, ['Laravel', 'PHP']);
      expect(
        carla.experiences.map((e) => '${e.title}:${e.kind.name}'),
        unorderedEquals(['Stage:experience', 'Licence:education']),
      );
      // Retour à l'écran de départ.
      expect(find.text('ouvrir'), findsOneWidget);
      await _flushSnackBar(tester);
    });

    testWidgets('une compétence retirée avant création n\'est pas enregistrée',
        (tester) async {
      final provider = await _openForm(tester);
      await _fill(tester, 'Nom complet *', 'Carla Petit');
      await _fill(tester, 'Filière / niveau *', 'Info');

      for (final name in ['Java', 'Python']) {
        await _tap(tester, find.byTooltip('Ajouter une compétence'));
        await tester.enterText(find.widgetWithText(TextFormField, 'Nom *'), name);
        await _tap(tester, find.text('Ajouter'));
      }
      // Retire « Java » (premier bouton « Retirer »).
      await _tap(tester, find.byTooltip('Retirer').first);
      expect(find.text('Java'), findsNothing);

      await _tap(tester, find.text('Créer le portfolio'));

      expect(_created(provider, 'Carla Petit').skills.map((s) => s.name),
          ['Python']);
      await _flushSnackBar(tester);
    });

    testWidgets('filière obligatoire : rien n\'est créé', (tester) async {
      final provider = await _openForm(tester);
      await _fill(tester, 'Nom complet *', 'Carla Petit');

      await _tap(tester, find.text('Créer le portfolio'));
      await _reveal(tester, find.text('La filière est obligatoire'));

      expect(find.text('La filière est obligatoire'), findsOneWidget);
      expect(provider.students, hasLength(1));
      expect(_repo.writes, 0);
    });

    testWidgets('« Annuler » ne crée rien', (tester) async {
      final provider = await _openForm(tester);
      await _fill(tester, 'Nom complet *', 'Carla Petit');
      await _fill(tester, 'Filière / niveau *', 'Info');

      await _tap(tester, find.text('Annuler'));

      expect(find.text('ouvrir'), findsOneWidget);
      expect(provider.students, hasLength(1));
      expect(_repo.writes, 0);
    });

    // Le pseudo sert à construire l'adresse de l'API GitHub et le lien du PDF :
    // une adresse collée en entier doit être ramenée au pseudo.
    for (final (saisie, pseudo) in [
      (' alice ', 'alice'),
      ('@alice', 'alice'),
      ('https://github.com/alice', 'alice'),
      ('github.com/alice/', 'alice'),
      ('https://www.github.com/alice?tab=repositories', 'alice'),
    ]) {
      testWidgets('pseudo GitHub « $saisie » enregistré « $pseudo »',
          (tester) async {
        final provider = await _openForm(tester);
        await _fill(tester, 'Nom complet *', 'Carla Petit');
        await _fill(tester, 'Filière / niveau *', 'Info');
        await _fill(tester, 'Pseudo GitHub (optionnel)', saisie);

        await _tap(tester, find.text('Créer le portfolio'));

        expect(_created(provider, 'Carla Petit').githubUsername, pseudo);
        await _flushSnackBar(tester);
      });
    }

    for (final mauvais in ['alice@', 'alice.example.com', 'alice@exemple', 'a b@c.com']) {
      testWidgets('e-mail « $mauvais » refusé', (tester) async {
        final provider = await _openForm(tester);
        await _fill(tester, 'Nom complet *', 'Carla Petit');
        await _fill(tester, 'Filière / niveau *', 'Info');
        await _fill(tester, 'E-mail (optionnel)', mauvais);

        await _tap(tester, find.text('Créer le portfolio'));
        await _reveal(tester, find.text('Adresse e-mail invalide'));

        expect(find.text('Adresse e-mail invalide'), findsOneWidget);
        expect(provider.students, hasLength(1));
      });
    }
  });

  group('Vérification du compte GitHub', () {
    Future<void> fillRequired(WidgetTester tester, String github) async {
      await _fill(tester, 'Nom complet *', 'Carla Petit');
      await _fill(tester, 'Filière / niveau *', 'Info');
      await _fill(tester, 'Pseudo GitHub (optionnel)', github);
    }

    testWidgets('compte existant : CV créé après avoir interrogé GitHub',
        (tester) async {
      final provider = await _openForm(tester);
      await fillRequired(tester, 'https://github.com/carla');

      await _tap(tester, find.text('Créer le portfolio'));

      expect(_githubCalls.single.toString(),
          'https://api.github.com/users/carla');
      expect(_created(provider, 'Carla Petit').githubUsername, 'carla');
      expect(find.text('Portfolio enregistré'), findsOneWidget);
      await _flushSnackBar(tester);
    });

    testWidgets('compte inexistant : erreur sous le champ, rien n\'est créé',
        (tester) async {
      final provider = await _openForm(tester, githubStatus: 404);
      await fillRequired(tester, 'carla-inconnue');

      await _tap(tester, find.text('Créer le portfolio'));

      // On reste sur le formulaire, le message est visible à l'écran.
      expect(find.text('Aucun compte GitHub à ce nom').hitTestable(),
          findsOneWidget);
      expect(find.text('ouvrir'), findsNothing);
      expect(provider.students, hasLength(1));
      expect(_repo.writes, 0);
    });

    testWidgets('corriger le pseudo refusé efface l\'erreur', (tester) async {
      await _openForm(tester, githubStatus: 404);
      await fillRequired(tester, 'carla-inconnue');
      await _tap(tester, find.text('Créer le portfolio'));
      expect(find.text('Aucun compte GitHub à ce nom'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Pseudo GitHub (optionnel)'),
          'carla');
      await tester.pumpAndSettle(); // le message disparaît en fondu

      expect(find.text('Aucun compte GitHub à ce nom'), findsNothing);
    });

    testWidgets('hors ligne : CV créé quand même, avec un avertissement',
        (tester) async {
      final provider = await _openForm(tester, githubOffline: true);
      await fillRequired(tester, 'carla');

      await _tap(tester, find.text('Créer le portfolio'));

      expect(_created(provider, 'Carla Petit').githubUsername, 'carla');
      expect(
        find.text('Portfolio enregistré, mais le pseudo GitHub n\'a pas pu '
            'être vérifié (GitHub injoignable).'),
        findsOneWidget,
      );
      await _flushSnackBar(tester);
    });

    testWidgets('forme impossible : refusée tout de suite, sans réseau',
        (tester) async {
      final provider = await _openForm(tester);
      await fillRequired(tester, 'carla petit');

      await _tap(tester, find.text('Créer le portfolio'));
      await _reveal(tester,
          find.text('Pseudo GitHub invalide (lettres, chiffres et tirets)'));

      expect(
          find.text('Pseudo GitHub invalide (lettres, chiffres et tirets)'),
          findsOneWidget);
      expect(_githubCalls, isEmpty);
      expect(provider.students, hasLength(1));
    });

    testWidgets('sans pseudo : aucun appel à GitHub', (tester) async {
      final provider = await _openForm(tester);
      await _fill(tester, 'Nom complet *', 'Carla Petit');
      await _fill(tester, 'Filière / niveau *', 'Info');

      await _tap(tester, find.text('Créer le portfolio'));

      expect(_githubCalls, isEmpty);
      expect(_created(provider, 'Carla Petit').githubUsername, isNull);
      await _flushSnackBar(tester);
    });

    testWidgets('pendant la vérification : roue de chargement, bouton bloqué',
        (tester) async {
      final provider = await _openForm(tester);
      await fillRequired(tester, 'carla');
      final Finder bouton = find.text('Créer le portfolio');
      await _reveal(tester, bouton);

      await tester.tap(bouton);
      await tester.pump(); // la requête GitHub (50 ms) est en cours
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(bouton, warnIfMissed: false); // 2e appui ignoré
      await tester.pumpAndSettle();

      expect(_githubCalls, hasLength(1));
      expect(provider.students.where((s) => s.fullName == 'Carla Petit'),
          hasLength(1));
      await _flushSnackBar(tester);
    });

    testWidgets('modification sans changer le pseudo : pas d\'appel GitHub',
        (tester) async {
      // Hors ligne exprès : modifier sa bio ne doit ni attendre ni avertir.
      final provider =
          await _openForm(tester, student: _alice, githubOffline: true);
      await _fill(tester, 'Localisation (optionnel)', 'Tunis');

      await _tap(tester, find.text('Enregistrer'));

      expect(_githubCalls, isEmpty);
      expect(provider.studentById(1).location, 'Tunis');
      expect(find.text('Portfolio enregistré'), findsOneWidget);
      await _flushSnackBar(tester);
    });
  });

  // Pendant la saisie du pseudo, les dépôts publics apparaissent sous le champ.
  group('Aperçu des dépôts pendant la saisie', () {
    final Finder champ =
        find.widgetWithText(TextFormField, 'Pseudo GitHub (optionnel)');

    /// Tape [pseudo] puis laisse passer le délai d'attente et la réponse.
    Future<void> typeAndWait(WidgetTester tester, String pseudo) async {
      await _reveal(tester, champ);
      await tester.enterText(champ, pseudo);
      await tester.pump(const Duration(milliseconds: 700)); // fin de frappe
      await tester.pumpAndSettle(); // réponse de GitHub
    }

    testWidgets('compte trouvé : ses 5 derniers dépôts, puis « + 2 autres »',
        (tester) async {
      await _openForm(tester, repos: {
        'carla': ['r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'],
      });
      await typeAndWait(tester, 'https://github.com/carla');

      expect(find.text('Compte GitHub trouvé'), findsOneWidget);
      for (final n in ['r1', 'r2', 'r3', 'r4', 'r5']) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
      expect(find.text('r6'), findsNothing);
      expect(find.text('+ 2 autres dépôts'), findsOneWidget);
      expect(_githubCalls.single.path, '/users/carla/repos');
    });

    testWidgets('pendant la recherche : message de chargement', (tester) async {
      await _openForm(tester, repos: {'carla': ['r1']});
      await _reveal(tester, champ);
      await tester.enterText(champ, 'carla');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(); // requête partie, réponse pas encore arrivée

      expect(find.text('Recherche du compte GitHub…'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Compte GitHub trouvé'), findsOneWidget);
    });

    testWidgets('compte sans dépôt public : dit qu\'il n\'y en a pas',
        (tester) async {
      await _openForm(tester);
      await typeAndWait(tester, 'carla');

      expect(find.text('Compte GitHub trouvé'), findsOneWidget);
      expect(find.text('Aucun dépôt public pour l\'instant'), findsOneWidget);
    });

    testWidgets('compte inexistant : erreur sous le champ sans rien valider',
        (tester) async {
      await _openForm(tester, githubStatus: 404);
      await typeAndWait(tester, 'carla-inconnue');

      expect(find.text('Aucun compte GitHub à ce nom'), findsOneWidget);
      expect(find.text('Compte GitHub trouvé'), findsNothing);
    });

    testWidgets('hors ligne : le dit, sans bloquer', (tester) async {
      await _openForm(tester, githubOffline: true);
      await typeAndWait(tester, 'carla');

      expect(
        find.text('Impossible de vérifier le compte pour l\'instant '
            '(connexion ?)'),
        findsOneWidget,
      );
    });

    testWidgets('frappe lettre par lettre : une seule requête, à la fin',
        (tester) async {
      await _openForm(tester, repos: {'carla': ['r1']});
      await _reveal(tester, champ);
      for (final debut in ['c', 'ca', 'car', 'carl', 'carla']) {
        await tester.enterText(champ, debut);
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(_githubCalls.map((u) => u.path), ['/users/carla/repos']);
    });

    testWidgets('réponse dépassée ignorée : seul le dernier pseudo s\'affiche',
        (tester) async {
      await _openForm(tester, repos: {
        'alice': ['depot-alice'],
        'bob': ['depot-bob'],
      });
      await _reveal(tester, champ);
      await tester.enterText(champ, 'alice');
      await tester.pump(const Duration(milliseconds: 700)); // requête alice
      await tester.enterText(champ, 'bob'); // avant la réponse (50 ms)
      // La réponse pour alice arrive maintenant : elle ne doit pas s'afficher
      // sous « bob », même un instant.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('depot-alice'), findsNothing);
      await tester.pump(const Duration(milliseconds: 600)); // requête bob
      await tester.pumpAndSettle();

      expect(find.text('depot-bob'), findsOneWidget);
      expect(find.text('depot-alice'), findsNothing);
    });

    testWidgets('forme impossible : aucun appel pendant la saisie',
        (tester) async {
      await _openForm(tester);
      await typeAndWait(tester, 'carla petit');

      expect(_githubCalls, isEmpty);
      expect(find.text('Compte GitHub trouvé'), findsNothing);
    });

    testWidgets('compte déjà trouvé : la création ne redemande pas à GitHub',
        (tester) async {
      final provider = await _openForm(tester, repos: {'carla': ['r1']});
      await _fill(tester, 'Nom complet *', 'Carla Petit');
      await _fill(tester, 'Filière / niveau *', 'Info');
      await typeAndWait(tester, 'carla');

      await _tap(tester, find.text('Créer le portfolio'));

      expect(_githubCalls, hasLength(1)); // celle de l'aperçu seulement
      expect(_created(provider, 'Carla Petit').githubUsername, 'carla');
      await _flushSnackBar(tester);
    });
  });

  group('Modification du profil', () {
    testWidgets('prérempli, sans les sections de contenu', (tester) async {
      await _openForm(tester, student: _alice);

      expect(find.text('Modifier le profil'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Alice Martin'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'alice@example.com'), findsOneWidget);
      // Le contenu se gère depuis la page profil, pas ici.
      expect(find.byTooltip('Ajouter une compétence'), findsNothing);
      expect(find.text('Enregistrer'), findsOneWidget);
    });

    testWidgets('vider un champ l\'efface ; le contenu est conservé',
        (tester) async {
      final provider = await _openForm(tester, student: _alice);

      await _fill(tester, 'E-mail (optionnel)', '   ');
      await _fill(tester, 'Pseudo GitHub (optionnel)', '');
      await _fill(tester, 'Localisation (optionnel)', 'Tunis');
      await _tap(tester, find.text('Enregistrer'));

      final Student a = provider.studentById(1);
      expect(a.email, isNull);
      expect(a.githubUsername, isNull);
      expect(a.location, 'Tunis');
      expect(a.phone, '+216 11 222 333'); // non touché
      expect(a.skills.map((s) => s.name), ['Dart']);
      expect(a.projects.map((p) => p.title), ['Appli']);
      expect(a.experiences.map((e) => e.title), ['Stage']);
      await _flushSnackBar(tester);
    });
  });
}
