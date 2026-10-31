/// Modèle représentant une **compétence** d'un étudiant.
///
/// Un « modèle » est une classe qui décrit la structure d'une donnée métier.
/// Ici, une compétence a un nom et un niveau de maîtrise.
class Skill {
  /// Identifiant unique. `null` tant que la compétence n'est pas enregistrée
  /// en base de données (il sera attribué par sqflite).
  final int? id;

  /// Nom de la compétence (ex : « Flutter »).
  final String name;

  /// Niveau de maîtrise, de 0 à 100 (pour une barre de progression).
  /// `null` si le niveau n'est pas précisé : dans ce cas on n'affiche pas de
  /// barre, pour ne pas **inventer** une valeur.
  final int? level;

  /// Constructeur. `const` permet de créer des compétences constantes.
  /// `required` rend le nom obligatoire ; le niveau est optionnel.
  const Skill({
    this.id,
    required this.name,
    this.level,
  });

  /// Convertit la compétence en `Map` pour l'enregistrer dans la base.
  /// (Le `studentId` est ajouté par le repository au moment de l'insertion.)
  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'level': level,
      };

  /// Reconstruit une compétence à partir d'une ligne de la base (un `Map`).
  factory Skill.fromMap(Map<String, Object?> map) => Skill(
        id: map['id'] as int?,
        name: map['name'] as String,
        level: map['level'] as int?,
      );
}
