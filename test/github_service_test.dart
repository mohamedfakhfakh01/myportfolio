import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportfolio/features/github/data/github_service.dart';

/// Tests du service GitHub, avec un client HTTP simulé (MockClient) : aucun
/// appel réseau réel. On vérifie la conversion JSON et la traduction des
/// erreurs (404, 403, délai dépassé, hors-ligne) en GithubException.
void main() {
  group('GithubService', () {
    test('200 : convertit le JSON en liste de dépôts', () async {
      final client = MockClient((_) async => http.Response(
            '[{"name":"myportfolio","html_url":"https://github.com/x/myportfolio",'
            '"stargazers_count":5,"language":"Dart"}]',
            200,
          ));
      final repos = await GithubService(client: client).fetchRepos('x');
      expect(repos, hasLength(1));
      expect(repos.first.name, 'myportfolio');
      expect(repos.first.stars, 5);
    });

    test('404 : lève GithubException', () async {
      final client = MockClient((_) async => http.Response('', 404));
      await expectLater(
        GithubService(client: client).fetchRepos('x'),
        throwsA(isA<GithubException>()),
      );
    });

    test('403 : lève GithubException (limite de requêtes)', () async {
      final client = MockClient((_) async => http.Response('', 403));
      await expectLater(
        GithubService(client: client).fetchRepos('x'),
        throwsA(isA<GithubException>()),
      );
    });

    test('délai dépassé : lève GithubException', () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('[]', 200);
      });
      final service = GithubService(
        client: client,
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(
        service.fetchRepos('x'),
        throwsA(isA<GithubException>()),
      );
    });

    test('hors-ligne (le client lève) : GithubException', () async {
      final client = MockClient((_) async => throw Exception('no network'));
      await expectLater(
        GithubService(client: client).fetchRepos('x'),
        throwsA(isA<GithubException>()),
      );
    });
  });

  test('réponse 200 illisible : GithubException (pas de plantage)', () async {
    final client = MockClient((_) async => http.Response('{}', 200));
    await expectLater(
      GithubService(client: client).fetchRepos('x'),
      throwsA(isA<GithubException>()),
    );
  });

  test('404 : l\'erreur indique « introuvable » ; demande perPage', () async {
    Uri? url;
    final client = MockClient((request) async {
      url = request.url;
      return http.Response('', 404);
    });
    await expectLater(
      GithubService(client: client).fetchRepos('x', perPage: 100),
      throwsA(isA<GithubException>().having((e) => e.notFound, 'notFound', true)),
    );
    expect(url!.queryParameters['per_page'], '100');
  });

  // Vérification d'existence d'un compte (formulaire « Ajouter un CV »).
  group('checkUser', () {
    /// Service dont le faux client répond [status] et note chaque adresse.
    (GithubService, List<Uri>) serviceAnswering(int status) {
      final calls = <Uri>[];
      final client = MockClient((request) async {
        calls.add(request.url);
        return http.Response('{}', status);
      });
      return (GithubService(client: client), calls);
    }

    test('200 : le compte existe (et on interroge /users/<pseudo>)', () async {
      final (service, calls) = serviceAnswering(200);
      expect(await service.checkUser('alice'), GithubUserStatus.exists);
      expect(calls.single.toString(), 'https://api.github.com/users/alice');
    });

    test('404 : le compte n\'existe pas', () async {
      final (service, _) = serviceAnswering(404);
      expect(await service.checkUser('alice'), GithubUserStatus.notFound);
    });

    test('403 (limite de requêtes) ou 500 : impossible de savoir', () async {
      for (final code in [403, 500]) {
        final (service, _) = serviceAnswering(code);
        expect(await service.checkUser('alice'), GithubUserStatus.unknown,
            reason: '$code');
      }
    });

    test('hors ligne : impossible de savoir, sans lever d\'erreur', () async {
      final client = MockClient((_) async => throw Exception('no network'));
      expect(await GithubService(client: client).checkUser('alice'),
          GithubUserStatus.unknown);
    });

    test('délai dépassé : impossible de savoir', () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return http.Response('{}', 200);
      });
      final service = GithubService(
        client: client,
        timeout: const Duration(milliseconds: 20),
      );
      expect(await service.checkUser('alice'), GithubUserStatus.unknown);
    });

    test('pseudo mal formé : « introuvable » sans appeler le réseau', () async {
      final (service, calls) = serviceAnswering(200);
      for (final mauvais in ['alice martin', 'alice/repos', 'élodie', '-alice']) {
        expect(await service.checkUser(mauvais), GithubUserStatus.notFound,
            reason: mauvais);
      }
      expect(calls, isEmpty);
    });
  });

  // Le service ne fabrique aucun texte : il indique le TYPE d'erreur, et
  // l'écran choisit le message traduit.
  group('type d\'erreur', () {
    Future<void> expectKind(GithubService service, GithubErrorKind kind) =>
        expectLater(
          service.fetchRepos('x'),
          throwsA(isA<GithubException>().having((e) => e.kind, 'kind', kind)),
        );

    test('404 → notFound, 403 → rateLimited, 500 → unexpected', () async {
      for (final (code, kind) in [
        (404, GithubErrorKind.notFound),
        (403, GithubErrorKind.rateLimited),
        (500, GithubErrorKind.unexpected),
      ]) {
        await expectKind(
          GithubService(client: MockClient((_) async => http.Response('', code))),
          kind,
        );
      }
    });

    test('hors ligne → offline ; délai → timeout', () async {
      await expectKind(
        GithubService(client: MockClient((_) async => throw Exception('x'))),
        GithubErrorKind.offline,
      );
      await expectKind(
        GithubService(
          client: MockClient((_) async {
            await Future<void>.delayed(const Duration(milliseconds: 200));
            return http.Response('[]', 200);
          }),
          timeout: const Duration(milliseconds: 20),
        ),
        GithubErrorKind.timeout,
      );
    });
  });

  // Le total affiché sur le profil doit être EXACT : on récupère toutes les
  // pages (100 dépôts chacune) au lieu des 30 premiers dépôts seulement.
  group('fetchAllRepos', () {
    /// Faux GitHub : renvoie pages[n-1] dépôts pour la page n ; note les URL.
    (GithubService, List<Uri>) github(List<int> pages) {
      final calls = <Uri>[];
      final client = MockClient((request) async {
        calls.add(request.url);
        final int page = int.parse(request.url.queryParameters['page']!);
        final int n = page <= pages.length ? pages[page - 1] : 0;
        return http.Response(
          jsonEncode([
            for (int i = 0; i < n; i++)
              {'name': 'p$page-$i', 'html_url': 'https://github.com/x/$i'},
          ]),
          200,
        );
      });
      return (GithubService(client: client), calls);
    }

    test('19 dépôts : une seule requête de 100, liste complète', () async {
      final (service, calls) = github([19]);
      final r = await service.fetchAllRepos('x');
      expect(r.repos, hasLength(19));
      expect(r.complete, isTrue);
      expect(calls.single.queryParameters,
          containsPair('per_page', '100'));
    });

    test('120 dépôts : deux pages, total exact', () async {
      final (service, calls) = github([100, 20]);
      final r = await service.fetchAllRepos('x');
      expect(r.repos, hasLength(120));
      expect(r.complete, isTrue);
      expect(calls.map((u) => u.queryParameters['page']), ['1', '2']);
    });

    test('exactement 100 : une page vide confirme la fin', () async {
      final (service, calls) = github([100]);
      final r = await service.fetchAllRepos('x');
      expect(r.repos, hasLength(100));
      expect(r.complete, isTrue);
      expect(calls, hasLength(2));
    });

    test('au-delà de la limite de pages : « incomplet », pas de faux total',
        () async {
      final (service, calls) = github([100, 100, 100]);
      final r = await service.fetchAllRepos('x', maxPages: 2);
      expect(r.repos, hasLength(200));
      expect(r.complete, isFalse);
      expect(calls, hasLength(2)); // s'arrête : ménage la limite GitHub
    });
  });
}
