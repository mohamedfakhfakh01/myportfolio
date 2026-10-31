/// Catégorie d'une compétence, pour regrouper l'affichage sur le profil.
///
/// On stocke en base le `name` technique (ex : « language ») ; le libellé
/// affiché est **traduit** à l'affichage (voir `skillCategoryLabel`), pour
/// garder une seule source de vérité (les fichiers de traduction).
enum SkillCategory {
  language,
  framework,
  tool,
  other;

  /// Retrouve une catégorie depuis son nom technique stocké en base.
  /// Si la valeur est inconnue ou absente, on retombe sur [SkillCategory.other].
  static SkillCategory fromName(String? name) => SkillCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => SkillCategory.other,
      );
}

/// Modèle représentant une **compétence** d'un étudiant.
///
/// Un « modèle » est une classe qui décrit la structure d'une donnée métier.
/// Ici, une compétence a un nom, un niveau de maîtrise et une catégorie.
class Skill {
  /// Identifiant unique. `null` tant que la compétence n'est pas enregistrée
  /// en base de données (il sera attribué par sqflite à l'étape 8).
  final int? id;

  /// Nom de la compétence (ex : « Flutter »).
  final String name;

  /// Niveau de maîtrise, de 0 à 100 (pour une barre de progression).
  /// `null` si le niveau n'est pas précisé : dans ce cas on n'affiche pas de
  /// barre, pour ne pas **inventer** une valeur.
  final int? level;

  /// Catégorie (langage, framework, outil…). Par défaut [SkillCategory.other].
  final SkillCategory category;

  /// Constructeur. `const` permet de créer des compétences constantes.
  /// `required` rend le nom obligatoire ; les autres champs sont optionnels.
  const Skill({
    this.id,
    required this.name,
    this.level,
    this.category = SkillCategory.other,
  });

  /// Convertit la compétence en `Map` pour l'enregistrer dans la base.
  /// (Le `studentId` est ajouté par le repository au moment de l'insertion.)
  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'level': level,
        'category': category.name,
      };

  /// Reconstruit une compétence à partir d'une ligne de la base (un `Map`).
  /// `factory` = un constructeur qui peut faire un peu de logique avant de
  /// renvoyer l'objet.
  factory Skill.fromMap(Map<String, Object?> map) => Skill(
        id: map['id'] as int?,
        name: map['name'] as String,
        level: map['level'] as int?,
        category: SkillCategory.fromName(map['category'] as String?),
      );
}
