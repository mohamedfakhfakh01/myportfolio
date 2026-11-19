import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/utils/github.dart';
import 'github_repo.dart';

/// Erreur « métier » du service GitHub, avec un message lisible pour l'UI.
class GithubException implements Exception {
  GithubException(this.message, {this.notFound = false});
  final String message;

  /// Vrai si GitHub a répondu que ce compte n'existe pas (404) : l'écran peut
  /// alors afficher son propre message traduit.
  final bool notFound;

  @override
  String toString() => message;
}

/// Réponse de GitHub à « ce compte existe-t-il ? ».
enum GithubUserStatus {
  /// Le compte existe.
  exists,

  /// GitHub répond que ce compte n'existe pas (ou le pseudo est mal formé).
  notFound,

  /// Impossible de savoir : hors ligne, délai dépassé, limite de requêtes…
  unknown,
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
  ///
  /// [perPage] : nombre maximal de dépôts renvoyés (100 au plus pour GitHub).
  Future<List<GithubRepo>> fetchRepos(String username, {int perPage = 30}) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/users/$username/repos?sort=updated&per_page=$perPage',
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
        // Une réponse inattendue devient une erreur lisible, pas un plantage.
        try {
          final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
          return data
              .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (_) {
          throw GithubException('Réponse GitHub illisible.');
        }
      case 404:
        throw GithubException('Utilisateur GitHub introuvable.', notFound: true);
      case 403:
        throw GithubException(
          'Limite de requêtes GitHub atteinte. Réessaie dans un moment.',
        );
      default:
        throw GithubException('Erreur GitHub (code ${response.statusCode}).');
    }
  }

  /// Vérifie qu'un compte GitHub **existe** (`GET /users/<pseudo>`).
  ///
  /// Ne lève jamais d'erreur : un problème de réseau donne
  /// [GithubUserStatus.unknown], pour que l'appelant puisse continuer sans
  /// bloquer l'utilisateur hors ligne.
  Future<GithubUserStatus> checkUser(String username) async {
    // Un pseudo mal formé n'existe pas : inutile d'appeler le réseau (et on
    // n'envoie jamais une adresse cassée à l'API).
    if (!isValidGithubUsername(username)) return GithubUserStatus.notFound;
    try {
      final http.Response response = await _client
          .get(Uri.https('api.github.com', '/users/$username'),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(timeout);
      switch (response.statusCode) {
        case 200:
          return GithubUserStatus.exists;
        case 404:
          return GithubUserStatus.notFound;
        default: // 403 (limite de requêtes), 5xx…
          return GithubUserStatus.unknown;
      }
    } catch (_) {
      // Hors ligne, délai dépassé (TimeoutException)…
      return GithubUserStatus.unknown;
    }
  }
}
