import '../../../shared/models/experience.dart';
import '../../../shared/models/student.dart';

/// Résultat du calcul de complétion d'un portfolio.
class ProfileCompletion {
  const ProfileCompletion({required this.done, required this.total});

  /// Nombre de critères renseignés.
  final int done;

  /// Nombre total de critères.
  final int total;

  /// Pourcentage arrondi (0 à 100).
  int get percent => total == 0 ? 0 : ((done / total) * 100).round();

  /// Valeur entre 0 et 1, pour l'anneau de progression.
  double get fraction => total == 0 ? 0 : done / total;
}

/// Calcule la complétion d'un portfolio à partir des données **réellement
/// saisies**.
///
/// Rien n'est inventé : chaque critère correspond à un champ que l'étudiant
/// peut remplir lui-même dans l'app. Le score est donc toujours justifiable.
ProfileCompletion profileCompletion(Student student) {
  bool filled(String? value) => value != null && value.trim().isNotEmpty;

  final List<bool> criteria = [
    filled(student.photoPath),
    filled(student.bio),
    filled(student.email),
    filled(student.phone),
    filled(student.linkedin),
    filled(student.location),
    filled(student.githubUsername),
    student.skills.isNotEmpty,
    student.projects.isNotEmpty,
    student.experiences.any((e) => e.kind == ExperienceKind.experience),
    student.experiences.any((e) => e.kind == ExperienceKind.education),
  ];

  return ProfileCompletion(
    done: criteria.where((ok) => ok).length,
    total: criteria.length,
  );
}
