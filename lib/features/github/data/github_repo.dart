/// Modèle d'un **dépôt GitHub** tel qu'on l'affiche dans l'application.
///
/// On ne garde que les champs utiles (l'API GitHub en renvoie beaucoup plus).
class GithubRepo {
  /// Nom du dépôt (ex : « myportfolio »).
  final String name;

  /// Description du dépôt (peut être absente sur GitHub → `null`).
  final String? description;

  /// Langage principal (peut être absent → `null`).
  final String? language;

  /// Nombre d'étoiles ⭐.
  final int stars;

  /// Lien vers le dépôt sur github.com.
  final String htmlUrl;

  /// Date de dernière mise à jour (peut être absente → `null`).
  final DateTime? updatedAt;

  const GithubRepo({
    required this.name,
    this.description,
    this.language,
    this.stars = 0,
    required this.htmlUrl,
    this.updatedAt,
  });

  /// Construit un `GithubRepo` à partir d'un objet JSON renvoyé par l'API.
  ///
  /// Les noms des clés (`stargazers_count`, `html_url`…) sont ceux de l'API
  /// GitHub ; on les « traduit » vers nos propres champs.
  factory GithubRepo.fromJson(Map<String, dynamic> json) => GithubRepo(
        name: json['name'] as String,
        description: json['description'] as String?,
        language: json['language'] as String?,
        stars: (json['stargazers_count'] as int?) ?? 0,
        htmlUrl: json['html_url'] as String,
        updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? ''),
      );
}
