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
}
