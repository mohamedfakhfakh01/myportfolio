import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Faux dépôt **en mémoire, avec état** : il rejoue le comportement de la
/// base (ajout / modification / suppression de projets, compétences et
/// entrées du parcours) sans sqflite. Partagé par les tests d'écrans.
///
/// Chaque écriture « prend un peu de temps » (une attente asynchrone), comme
/// une vraie base : c'est ce qui permet de reproduire un double appui sur
/// « Enregistrer » pendant qu'un enregistrement est en cours.
class FakePortfolioRepository extends PortfolioRepository {
  FakePortfolioRepository(List<Student> students)
      : _students = List<Student>.of(students);

  final List<Student> _students;
  int _nextId = 1000;

  /// Nombre d'écritures reçues (pour vérifier qu'une action n'écrit qu'une fois).
  int writes = 0;

  Future<void> _write() async {
    writes++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  int _indexOf(int studentId) => _students.indexWhere((s) => s.id == studentId);

  /// Applique [change] à l'étudiant qui possède l'élément [match].
  void _updateOwner(
    bool Function(Student s) match,
    Student Function(Student s) change,
  ) {
    final int i = _students.indexWhere(match);
    if (i != -1) _students[i] = change(_students[i]);
  }

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<List<Student>> getStudents() async => List<Student>.of(_students);

  // --- Portfolios ---

  @override
  Future<int> insertStudent(Student student) async {
    await _write();
    final int id = _nextId++;
    // Comme la vraie base : seule la ligne « étudiant » est insérée ; le
    // contenu (compétences, projets, parcours) est ajouté ensuite.
    _students.add(student.copyWith(
      id: id,
      skills: const [],
      projects: const [],
      experiences: const [],
    ));
    return id;
  }

  @override
  Future<void> updateStudent(Student student) async {
    await _write();
    final int i = _indexOf(student.id!);
    // Remplace les champs du profil (y compris ceux vidés → null), garde
    // le contenu existant.
    _students[i] = student.copyWith(
      skills: _students[i].skills,
      projects: _students[i].projects,
      experiences: _students[i].experiences,
    );
  }

  @override
  Future<void> deleteStudent(int id) async {
    await _write();
    _students.removeWhere((s) => s.id == id);
  }

  // --- Projets ---

  @override
  Future<int> insertProject(Project project, int studentId) async {
    await _write();
    final int id = _nextId++;
    final int i = _indexOf(studentId);
    _students[i] = _students[i].copyWith(projects: [
      ..._students[i].projects,
      Project(
        id: id,
        title: project.title,
        description: project.description,
        link: project.link,
        imagePath: project.imagePath,
        tags: project.tags,
      ),
    ]);
    return id;
  }

  @override
  Future<void> updateProject(Project project) async {
    await _write();
    _updateOwner(
      (s) => s.projects.any((p) => p.id == project.id),
      (s) => s.copyWith(
        projects: [for (final p in s.projects) p.id == project.id ? project : p],
      ),
    );
  }

  @override
  Future<void> deleteProject(int id) async {
    await _write();
    _updateOwner(
      (s) => s.projects.any((p) => p.id == id),
      (s) => s.copyWith(projects: s.projects.where((p) => p.id != id).toList()),
    );
  }

  // --- Compétences ---

  @override
  Future<int> insertSkill(Skill skill, int studentId) async {
    await _write();
    final int id = _nextId++;
    final int i = _indexOf(studentId);
    _students[i] = _students[i].copyWith(skills: [
      ..._students[i].skills,
      Skill(id: id, name: skill.name, level: skill.level, category: skill.category),
    ]);
    return id;
  }

  @override
  Future<void> updateSkill(Skill skill) async {
    await _write();
    _updateOwner(
      (s) => s.skills.any((k) => k.id == skill.id),
      (s) => s.copyWith(
        skills: [for (final k in s.skills) k.id == skill.id ? skill : k],
      ),
    );
  }

  @override
  Future<void> deleteSkill(int id) async {
    await _write();
    _updateOwner(
      (s) => s.skills.any((k) => k.id == id),
      (s) => s.copyWith(skills: s.skills.where((k) => k.id != id).toList()),
    );
  }

  // --- Parcours ---

  @override
  Future<int> insertExperience(ExperienceEntry entry, int studentId) async {
    await _write();
    final int id = _nextId++;
    final int i = _indexOf(studentId);
    _students[i] = _students[i].copyWith(experiences: [
      ..._students[i].experiences,
      ExperienceEntry(
        id: id,
        title: entry.title,
        organization: entry.organization,
        period: entry.period,
        description: entry.description,
        kind: entry.kind,
      ),
    ]);
    return id;
  }

  @override
  Future<void> updateExperience(ExperienceEntry entry) async {
    await _write();
    _updateOwner(
      (s) => s.experiences.any((e) => e.id == entry.id),
      (s) => s.copyWith(
        experiences: [
          for (final e in s.experiences) e.id == entry.id ? entry : e,
        ],
      ),
    );
  }

  @override
  Future<void> deleteExperience(int id) async {
    await _write();
    _updateOwner(
      (s) => s.experiences.any((e) => e.id == id),
      (s) => s.copyWith(
        experiences: s.experiences.where((e) => e.id != id).toList(),
      ),
    );
  }
}
