// Section « Dépôts GitHub » du profil : chaque erreur doit s'afficher dans la
// langue de l'app. (Bug réel : les messages restaient en français dans l'app
// en anglais, car le service les écrivait en dur.)

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportfolio/features/github/data/github_service.dart';
import 'package:myportfolio/features/github/presentation/widgets/github_repos_section.dart';
import 'package:myportfolio/l10n/app_localizations.dart';

/// Affiche la section avec un faux GitHub dont [answer] produit la réponse.
Future<void> _pump(
  WidgetTester tester,
  Future<http.Response> Function() answer, {
  Locale locale = const Locale('fr'),
}) async {
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: GithubReposSection(
          username: 'alice',
          service: GithubService(
            client: MockClient((_) => answer()),
            timeout: const Duration(seconds: 1),
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<http.Response> Function() _status(int code) =>
    () async => http.Response('', code);

Future<http.Response> _offline() async => throw Exception('pas de réseau');

Future<http.Response> _tooSlow() async {
  await Future<void>.delayed(const Duration(seconds: 5));
  return http.Response('[]', 200);
}

void main() {
  group('Erreurs traduites', () {
    final cas = <(String, Future<http.Response> Function(), String, String)>[
      ('introuvable (404)', _status(404), 'Utilisateur GitHub introuvable.',
          'GitHub user not found.'),
      ('limite atteinte (403)', _status(403),
          'Limite de requêtes GitHub atteinte. Réessaie dans un moment.',
          'GitHub request limit reached. Try again in a moment.'),
      ('hors ligne', _offline, 'Impossible de contacter GitHub (connexion ?).',
          "Couldn't reach GitHub (connection?)."),
      ('délai dépassé', _tooSlow,
          'Délai dépassé. Vérifie ta connexion et réessaie.',
          'Request timed out. Check your connection and try again.'),
      ('réponse inattendue (500)', _status(500),
          'GitHub a renvoyé une réponse inattendue. Réessaie plus tard.',
          'GitHub sent an unexpected response. Try again later.'),
    ];

    for (final (nom, answer, fr, en) in cas) {
      testWidgets('$nom : français', (tester) async {
        await _pump(tester, answer);
        expect(find.text(fr), findsOneWidget);
        expect(find.text('Réessayer'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5)); // fin du faux délai
      });

      testWidgets('$nom : anglais', (tester) async {
        await _pump(tester, answer, locale: const Locale('en'));
        expect(find.text(en), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5)); // fin du faux délai
      });
    }
  });

  testWidgets('« Réessayer » relance et affiche les dépôts', (tester) async {
    int calls = 0;
    await _pump(tester, () async {
      calls++;
      if (calls == 1) throw Exception('pas de réseau');
      return http.Response(
        jsonEncode([
          {'name': 'myportfolio', 'html_url': 'https://github.com/a/m'},
        ]),
        200,
      );
    });
    expect(find.text('Impossible de contacter GitHub (connexion ?).'),
        findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('myportfolio'), findsOneWidget);
  });
}
