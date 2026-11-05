import 'skill.dart';
import 'project.dart';
import 'experience.dart';

/// Modèle représentant un **étudiant** et son portfolio complet.
///
/// Un étudiant regroupe ses informations personnelles/académiques, ainsi que
/// ses listes de compétences ([Skill]) et de projets ([Project]).
class Student {
  /// Identifiant unique (null tant que non enregistré en base).
  final int? id;

  /// Nom complet (ex : « Mohamed Fakhfakh »).
  final String fullName;

  /// Filière / niveau (ex : « 2e année informatique »).
  final String field;

  /// Courte présentation de l'étudiant.
  final String bio;

  /// Nom d'utilisateur GitHub (optionnel) — servira pour l'API REST (étape 9).
  final String? githubUsername;

  /// Chemin local de la photo de profil (optionnel). Null → on affiche les
  /// initiales à la place.
  final String? photoPath;

  /// Coordonnées de contact (toutes optionnelles).
  final String? email;
  final String? phone;
  final String? linkedin;
  final String? location;

  /// Liste des compétences de l'étudiant.
  final List<Skill> skills;

  /// Liste des projets de l'étudiant.
  final List<Project> projects;

  /// Parcours : expériences et formations.
  final List<ExperienceEntry> experiences;

  const Student({
    this.id,
    required this.fullName,
    required this.field,
    this.bio = '',
    this.githubUsername,
    this.photoPath,
    this.email,
    this.phone,
    this.linkedin,
    this.location,
    this.skills = const [],
    this.projects = const [],
    this.experiences = const [],
  });

  /// Initiales à afficher dans l'avatar (ex : « Mohamed Fakhfakh » → « MF »).
  ///
  /// C'est un *getter* : une propriété calculée à la volée à partir de
  /// `fullName`, plutôt qu'une donnée stockée.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Convertit l'étudiant en `Map` pour la table `students`.
  /// Les compétences et projets vivent dans d'autres tables : ils ne sont PAS
  /// inclus ici (le repository les enregistre séparément).
  Map<String, Object?> toMap() => {
        'id': id,
        'fullName': fullName,
        'field': field,
        'bio': bio,
        'githubUsername': githubUsername,
        'photoPath': photoPath,
        'email': email,
        'phone': phone,
        'linkedin': linkedin,
        'location': location,
      };

  /// Reconstruit un étudiant à partir d'une ligne `students` (sans ses listes).
  /// Le repository y rattachera ensuite les compétences/projets via [copyWith].
  factory Student.fromMap(Map<String, Object?> map) => Student(
        id: map['id'] as int?,
        fullName: map['fullName'] as String,
        field: map['field'] as String,
        bio: (map['bio'] as String?) ?? '',
        githubUsername: map['githubUsername'] as String?,
        photoPath: map['photoPath'] as String?,
        email: map['email'] as String?,
        phone: map['phone'] as String?,
        linkedin: map['linkedin'] as String?,
        location: map['location'] as String?,
      );

  /// Renvoie une copie de l'étudiant en remplaçant seulement les champs fournis.
  /// Sert à attacher les compétences/projets chargés séparément, et à l'édition
  /// du profil (sous-étape 8.6).
  Student copyWith({
    int? id,
    String? fullName,
    String? field,
    String? bio,
    String? githubUsername,
    String? photoPath,
    String? email,
    String? phone,
    String? linkedin,
    String? location,
    List<Skill>? skills,
    List<Project>? projects,
    List<ExperienceEntry>? experiences,
  }) =>
      Student(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        field: field ?? this.field,
        bio: bio ?? this.bio,
        githubUsername: githubUsername ?? this.githubUsername,
        photoPath: photoPath ?? this.photoPath,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        linkedin: linkedin ?? this.linkedin,
        location: location ?? this.location,
        skills: skills ?? this.skills,
        projects: projects ?? this.projects,
        experiences: experiences ?? this.experiences,
      );
}
