import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'github_repo.dart';

/// Erreur « métier » du service GitHub, avec un message lisible pour l'UI.
class GithubException implements Exception {
  GithubException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Service qui interroge l'**API REST publique de GitHub**.
///
/// Analogie : c'est le « fournisseur extérieur » de la cuisine. Il va chercher
/// des données hors de l'application, via le réseau (HTTP).
class GithubService {
  GithubService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  // Le `client` est injectable → on pourra le remplacer par un faux en test.
  final http.Client _client;

  /// Délai max d'attente réseau (injectable pour les tests).
  final Duration timeout;

  static const String _baseUrl = 'https://api.github.com';

  /// Récupère les dépôts publics d'un utilisateur GitHub.
  ///
  /// Étapes : construire l'URL → envoyer la requête `GET` → selon le **code de
  /// réponse** HTTP, lire le JSON (200) ou lever une erreur claire (404/403…).
  Future<List<GithubRepo>> fetchRepos(String username) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/users/$username/repos?sort=updated&per_page=30',
    );

    // On borne l'attente par un timeout et on traduit les erreurs réseau
    // (hors-ligne, délai dépassé) en messages lisibles.
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'Accept': 'application/vnd.github+json'})
          .timeout(timeout);
    } on TimeoutException {
      throw GithubException('Délai dépassé. Vérifie ta connexion et réessaie.');
    } catch (_) {
      throw GithubException('Impossible de contacter GitHub (connexion ?).');
    }

    switch (response.statusCode) {
      case 200:
        // Le corps est un tableau JSON ; on convertit chaque élément en objet.
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
            .toList();
      case 404:
        throw GithubException('Utilisateur GitHub introuvable.');
      case 403:
        throw GithubException(
          'Limite de requêtes GitHub atteinte. Réessaie dans un moment.',
        );
      default:
        throw GithubException('Erreur GitHub (code ${response.statusCode}).');
    }
  }
}
