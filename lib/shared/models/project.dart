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

  const Project({
    this.id,
    required this.title,
    required this.description,
    this.link,
  });

  /// Convertit le projet en `Map` pour l'enregistrer dans la base.
  /// (Le `studentId` est ajouté par le repository au moment de l'insertion.)
  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'link': link,
      };

  /// Reconstruit un projet à partir d'une ligne de la base.
  factory Project.fromMap(Map<String, Object?> map) => Project(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String,
        link: map['link'] as String?,
      );
}
