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
}
