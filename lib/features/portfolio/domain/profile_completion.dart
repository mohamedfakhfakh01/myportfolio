import '../../../shared/models/experience.dart';
import '../../../shared/models/student.dart';

/// Les critères qui composent la complétion d'un portfolio.
///
/// Chacun correspond à un champ que l'étudiant peut remplir lui-même : le
/// score reste donc toujours justifiable, et la liste des manquants est
/// directement une liste de choses à faire.
enum ProfileCriterion {
  photo,
  bio,
  email,
  phone,
  linkedin,
  location,
  github,
  skills,
  projects,
  experience,
  education,
}

/// Résultat du calcul de complétion d'un portfolio.
class ProfileCompletion {
  const ProfileCompletion({required this.missing, required this.total});

  /// Critères qu'il reste à renseigner, dans l'ordre d'affichage.
  final List<ProfileCriterion> missing;

  /// Nombre total de critères évalués.
  final int total;

  /// Nombre de critères déjà renseignés.
  int get done => total - missing.length;

  /// Pourcentage arrondi (0 à 100).
  int get percent => total == 0 ? 0 : ((done / total) * 100).round();

  /// Valeur entre 0 et 1, pour l'anneau de progression.
  double get fraction => total == 0 ? 0 : done / total;

  /// Vrai quand plus rien ne manque.
  bool get isComplete => missing.isEmpty;
}

/// Calcule la complétion d'un portfolio à partir des données **réellement
/// saisies**. Rien n'est inventé.
ProfileCompletion profileCompletion(Student student) {
  bool filled(String? value) => value != null && value.trim().isNotEmpty;

  // L'ordre des entrées est conservé : c'est l'ordre d'affichage.
  final Map<ProfileCriterion, bool> checks = {
    ProfileCriterion.photo: filled(student.photoPath),
    ProfileCriterion.bio: filled(student.bio),
    ProfileCriterion.email: filled(student.email),
    ProfileCriterion.phone: filled(student.phone),
    ProfileCriterion.linkedin: filled(student.linkedin),
    ProfileCriterion.location: filled(student.location),
    ProfileCriterion.github: filled(student.githubUsername),
    ProfileCriterion.skills: student.skills.isNotEmpty,
    ProfileCriterion.projects: student.projects.isNotEmpty,
    ProfileCriterion.experience:
        student.experiences.any((e) => e.kind == ExperienceKind.experience),
    ProfileCriterion.education:
        student.experiences.any((e) => e.kind == ExperienceKind.education),
  };

  return ProfileCompletion(
    missing: [
      for (final entry in checks.entries)
        if (!entry.value) entry.key,
    ],
    total: checks.length,
  );
}
