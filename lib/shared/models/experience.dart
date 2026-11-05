/// Type d'une entrée de **parcours** : expérience professionnelle ou formation.
///
/// On stocke en base le `name` technique (« experience »/« education ») ; le
/// libellé affiché est traduit à l'affichage, comme pour [SkillCategory].
enum ExperienceKind {
  experience,
  education;

  /// Retrouve un type depuis son nom technique ; par défaut [experience].
  static ExperienceKind fromName(String? name) =>
      ExperienceKind.values.firstWhere(
        (k) => k.name == name,
        orElse: () => ExperienceKind.experience,
      );
}

/// Une entrée du **parcours** d'un étudiant : une expérience (stage, emploi…)
/// ou une formation (diplôme, cursus…).
///
/// La période est un **texte libre** (ex : « 2024 – 2027 ») et non une date :
/// les CV utilisent des formats variés, et on n'invente pas de dates précises.
class ExperienceEntry {
  /// Identifiant unique (null tant que non enregistré en base).
  final int? id;

  /// Intitulé (ex : « Stagiaire Développeur Web », « Licence en Informatique »).
  final String title;

  /// Organisation / établissement (ex : « Tekru Technologies », « IIT Sfax »).
  final String? organization;

  /// Période, texte libre (ex : « Juin – Juillet 2026 », « 2024 – 2027 »).
  final String? period;

  /// Détails complémentaires (optionnel).
  final String? description;

  /// Type d'entrée (expérience ou formation).
  final ExperienceKind kind;

  const ExperienceEntry({
    this.id,
    required this.title,
    this.organization,
    this.period,
    this.description,
    this.kind = ExperienceKind.experience,
  });

  /// Convertit l'entrée en `Map` pour la table `experiences`.
  /// (Le `studentId` est ajouté par le repository au moment de l'insertion.)
  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'organization': organization,
        'period': period,
        'description': description,
        'kind': kind.name,
      };

  /// Reconstruit une entrée à partir d'une ligne de la base.
  factory ExperienceEntry.fromMap(Map<String, Object?> map) => ExperienceEntry(
        id: map['id'] as int?,
        title: map['title'] as String,
        organization: map['organization'] as String?,
        period: map['period'] as String?,
        description: map['description'] as String?,
        kind: ExperienceKind.fromName(map['kind'] as String?),
      );
}
