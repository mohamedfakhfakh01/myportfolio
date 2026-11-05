import 'dart:convert';

/// Modèle représentant un **projet** réalisé par un étudiant.
class Project {
  /// Identifiant unique (null tant que non enregistré en base).
  final int? id;

  /// Titre du projet (ex : « MyPortfolio »).
  final String title;

  /// Description courte du projet.
  final String description;

  /// Lien optionnel (ex : dépôt GitHub). `null` s'il n'y en a pas.
  final String? link;

  /// Chemin local d'une capture d'écran du projet (optionnel).
  final String? imagePath;

  /// Technologies utilisées (ex : Flutter, Dart). Vide si non renseigné.
  final List<String> tags;

  const Project({
    this.id,
    required this.title,
    required this.description,
    this.link,
    this.imagePath,
    this.tags = const [],
  });

  /// Convertit le projet en `Map` pour l'enregistrer dans la base.
  /// (Le `studentId` est ajouté par le repository au moment de l'insertion.)
  /// Les technologies sont sérialisées en JSON (SQLite n'a pas de type liste).
  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'link': link,
        'imagePath': imagePath,
        'tags': jsonEncode(tags),
      };

  /// Reconstruit un projet à partir d'une ligne de la base.
  factory Project.fromMap(Map<String, Object?> map) => Project(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String,
        link: map['link'] as String?,
        imagePath: map['imagePath'] as String?,
        tags: _decodeTags(map['tags']),
      );

  /// Décode la colonne `tags` (JSON) de façon tolérante : null, vide ou valeur
  /// invalide → liste vide (on n'invente rien).
  static List<String> _decodeTags(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) return const [];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Format inattendu : on ignore plutôt que de planter.
    }
    return const [];
  }
}
