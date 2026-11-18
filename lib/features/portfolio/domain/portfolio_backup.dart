import 'dart:convert';

import '../../../shared/models/experience.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/student.dart';

/// Version du format de sauvegarde. À incrémenter si la structure change,
/// pour pouvoir refuser (ou convertir) les anciens fichiers.
const int backupFormatVersion = 1;

/// Encode tous les portfolios en JSON lisible.
///
/// Les identifiants ne sont PAS exportés : à l'import, la base en attribue de
/// nouveaux. Les images sont référencées par leur chemin local : elles ne
/// suivent donc pas le fichier sur un autre appareil.
String encodePortfolioBackup(
  List<Student> students, {
  DateTime? exportedAt,
}) {
  final Map<String, Object?> data = {
    'format': backupFormatVersion,
    'exportedAt': (exportedAt ?? DateTime.now()).toIso8601String(),
    'students': [for (final s in students) _studentToJson(s)],
  };
  return const JsonEncoder.withIndent('  ').convert(data);
}

/// Décode une sauvegarde.
///
/// Lève une [FormatException] si le contenu n'est pas une sauvegarde valide,
/// pour que l'appelant puisse afficher un message clair plutôt que planter.
List<Student> decodePortfolioBackup(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } catch (_) {
    throw const FormatException('Fichier illisible : ce n\'est pas du JSON.');
  }

  if (decoded is! Map<String, Object?>) {
    throw const FormatException('Structure inattendue.');
  }
  final Object? students = decoded['students'];
  if (students is! List) {
    throw const FormatException('Aucun portfolio dans le fichier.');
  }

  return [
    for (final entry in students)
      if (entry is Map<String, Object?>) _studentFromJson(entry),
  ];
}

Map<String, Object?> _studentToJson(Student s) => {
      'fullName': s.fullName,
      'field': s.field,
      'bio': s.bio,
      'githubUsername': s.githubUsername,
      'photoPath': s.photoPath,
      'email': s.email,
      'phone': s.phone,
      'linkedin': s.linkedin,
      'location': s.location,
      'skills': [
        for (final k in s.skills)
          {'name': k.name, 'level': k.level, 'category': k.category.name},
      ],
      'projects': [
        for (final p in s.projects)
          {
            'title': p.title,
            'description': p.description,
            'link': p.link,
            'imagePath': p.imagePath,
            'tags': p.tags,
          },
      ],
      'experiences': [
        for (final e in s.experiences)
          {
            'title': e.title,
            'organization': e.organization,
            'period': e.period,
            'description': e.description,
            'kind': e.kind.name,
          },
      ],
    };

Student _studentFromJson(Map<String, Object?> map) {
  String? str(Object? v) => v is String && v.trim().isNotEmpty ? v : null;
  List<Map<String, Object?>> list(Object? v) => [
        for (final e in (v is List ? v : const []))
          if (e is Map<String, Object?>) e,
      ];

  return Student(
    fullName: str(map['fullName']) ?? 'Sans nom',
    field: str(map['field']) ?? '',
    bio: str(map['bio']) ?? '',
    githubUsername: str(map['githubUsername']),
    photoPath: str(map['photoPath']),
    email: str(map['email']),
    phone: str(map['phone']),
    linkedin: str(map['linkedin']),
    location: str(map['location']),
    skills: [
      for (final k in list(map['skills']))
        Skill(
          name: str(k['name']) ?? '',
          level: k['level'] is int ? k['level'] as int : null,
          category: SkillCategory.fromName(str(k['category'])),
        ),
    ],
    projects: [
      for (final p in list(map['projects']))
        Project(
          title: str(p['title']) ?? '',
          description: str(p['description']) ?? '',
          link: str(p['link']),
          imagePath: str(p['imagePath']),
          tags: [
            for (final t in (p['tags'] is List ? p['tags'] as List : const []))
              if (t is String && t.trim().isNotEmpty) t.trim(),
          ],
        ),
    ],
    experiences: [
      for (final e in list(map['experiences']))
        ExperienceEntry(
          title: str(e['title']) ?? '',
          organization: str(e['organization']),
          period: str(e['period']),
          description: str(e['description']),
          kind: ExperienceKind.fromName(str(e['kind'])),
        ),
    ],
  );
}
