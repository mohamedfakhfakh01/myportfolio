import 'package:flutter/foundation.dart';

import '../../../shared/models/experience.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/student.dart';
import '../data/portfolio_repository.dart';

/// Gère l'**état** des portfolios : la liste des étudiants, chargée depuis la
/// base de données via le [PortfolioRepository].
///
/// Gère trois états visibles par l'interface :
/// - `isLoading` : chargement en cours (on affiche un indicateur) ;
/// - `error` : un problème est survenu (on affiche un message) ;
/// - sinon : la liste `students` est prête.
class PortfolioProvider extends ChangeNotifier {
  /// Le repository est injectable (pratique pour les tests) ; par défaut on
  /// utilise le vrai, branché sur sqflite.
  PortfolioProvider({PortfolioRepository? repository})
      : _repository = repository ?? PortfolioRepository() {
    load();
  }

  final PortfolioRepository _repository;

  List<Student> _students = [];
  bool _isLoading = true;
  String? _error;

  /// Liste des étudiants (lecture seule).
  List<Student> get students => List.unmodifiable(_students);

  /// Vrai tant que les données ne sont pas chargées.
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel (null si tout va bien).
  String? get error => _error;

  /// Charge les étudiants depuis la base. Au tout premier lancement, remplit
  /// d'abord la base (seed). Gère les erreurs pour ne jamais planter l'app.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.seedIfEmpty();
      // Ajoute le profil de démonstration s'il manque (idempotent).
      await _repository.ensureDemoStudent();
      _students = await _repository.getStudents();
    } catch (e) {
      _error = 'Impossible de charger les données.';
      _students = [];
      debugPrint('Erreur de chargement des portfolios : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retrouve un étudiant par son identifiant (utile pour l'écran profil).
  Student studentById(int id) =>
      _students.firstWhere((student) => student.id == id);

  // ---------------------------------------------------------------------------
  // CRUD — COMPÉTENCES
  // Chaque opération écrit en base puis recharge la liste pour rafraîchir l'UI.
  // ---------------------------------------------------------------------------

  Future<void> addSkill(int studentId, Skill skill) async {
    await _repository.insertSkill(skill, studentId);
    await _reloadStudents();
  }

  Future<void> updateSkill(Skill skill) async {
    await _repository.updateSkill(skill);
    await _reloadStudents();
  }

  Future<void> deleteSkill(int skillId) async {
    await _repository.deleteSkill(skillId);
    await _reloadStudents();
  }

  // ---------------------------------------------------------------------------
  // CRUD — PROJETS
  // ---------------------------------------------------------------------------

  Future<void> addProject(int studentId, Project project) async {
    await _repository.insertProject(project, studentId);
    await _reloadStudents();
  }

  Future<void> updateProject(Project project) async {
    await _repository.updateProject(project);
    await _reloadStudents();
  }

  Future<void> deleteProject(int projectId) async {
    await _repository.deleteProject(projectId);
    await _reloadStudents();
  }

  // ---------------------------------------------------------------------------
  // CRUD — PARCOURS (expériences & formations)
  // ---------------------------------------------------------------------------

  Future<void> addExperience(int studentId, ExperienceEntry entry) async {
    await _repository.insertExperience(entry, studentId);
    await _reloadStudents();
  }

  Future<void> updateExperience(ExperienceEntry entry) async {
    await _repository.updateExperience(entry);
    await _reloadStudents();
  }

  Future<void> deleteExperience(int experienceId) async {
    await _repository.deleteExperience(experienceId);
    await _reloadStudents();
  }

  // ---------------------------------------------------------------------------
  // PROFIL ÉTUDIANT
  // ---------------------------------------------------------------------------

  /// Met à jour les champs du profil (nom, filière, bio, GitHub).
  Future<void> updateStudent(Student student) async {
    // Renommer vers le nom d'un AUTRE portfolio créerait un doublon.
    if (nameExists(student.fullName, excludeId: student.id)) {
      throw DuplicatePortfolioNameException(student.fullName);
    }
    await _repository.updateStudent(student);
    await _reloadStudents();
  }

  /// Crée un nouvel étudiant (nouveau portfolio), éventuellement avec des
  /// projets saisis dès la création.
  Future<void> addStudent(
    Student student, {
    List<Project> projects = const [],
  }) async {
    // Garde-fou : l'interface prévient déjà, mais AUCUN chemin ne doit pouvoir
    // créer un doublon (le provider fait foi, comme un serveur).
    if (nameExists(student.fullName)) {
      throw DuplicatePortfolioNameException(student.fullName);
    }
    await _insertStudentWithContent(student, projects: projects);
    await _reloadStudents();
  }

  /// Importe des portfolios issus d'une sauvegarde, **sans créer de doublon**.
  ///
  /// Un import est une *restauration* : si un portfolio porte déjà le même nom,
  /// il est **remplacé** par celui du fichier (et non ajouté une seconde fois).
  /// On remplace plutôt qu'on ignore, sinon une réinstallation — qui recrée les
  /// portfolios d'exemple — empêcherait de récupérer ses vraies données.
  Future<ImportResult> importStudents(List<Student> students) async {
    int added = 0;
    int replaced = 0;

    for (final student in students) {
      final Student? existing = _findByName(student.fullName);
      if (existing?.id != null) {
        // La suppression retire aussi compétences, projets et parcours
        // (clés étrangères ON DELETE CASCADE).
        await _repository.deleteStudent(existing!.id!);
        replaced++;
      } else {
        added++;
      }
      await _insertStudentWithContent(student, projects: student.projects);
      // On recharge à chaque tour pour que le doublon soit aussi détecté
      // lorsqu'il se trouve DANS le fichier importé.
      _students = await _repository.getStudents();
    }

    notifyListeners();
    return ImportResult(added: added, replaced: replaced);
  }

  /// Vrai si un portfolio porte déjà ce nom (casse et espaces ignorés).
  ///
  /// [excludeId] écarte un portfolio de la recherche : lors d'une modification,
  /// garder SON propre nom n'est pas un doublon.
  bool nameExists(String fullName, {int? excludeId}) {
    final String key = _normalizeName(fullName);
    return _students.any(
      (s) => s.id != excludeId && _normalizeName(s.fullName) == key,
    );
  }

  /// Retrouve un portfolio par son nom (casse et espaces ignorés).
  Student? _findByName(String fullName) {
    final String key = _normalizeName(fullName);
    for (final student in _students) {
      if (_normalizeName(student.fullName) == key) return student;
    }
    return null;
  }

  /// Forme canonique d'un nom, pour comparer « Alice Martin » et
  /// « alice  MARTIN ». Une seule définition, partagée par l'import et la
  /// création : les deux appliquent exactement la même règle.
  static String _normalizeName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Insère un étudiant puis tout son contenu. Utilisé par la création d'un
  /// portfolio et par l'import (une seule source de vérité).
  Future<void> _insertStudentWithContent(
    Student student, {
    required List<Project> projects,
  }) async {
    // On insère d'abord l'étudiant pour obtenir son id, puis ses compétences,
    // son parcours et ses projets.
    final int studentId = await _repository.insertStudent(student);
    for (final skill in student.skills) {
      await _repository.insertSkill(skill, studentId);
    }
    for (final exp in student.experiences) {
      await _repository.insertExperience(exp, studentId);
    }
    for (final project in projects) {
      await _repository.insertProject(project, studentId);
    }
  }

  /// Supprime un portfolio (étudiant) et rafraîchit la liste.
  Future<void> deleteStudent(int id) async {
    await _repository.deleteStudent(id);
    await _reloadStudents();
  }

  /// Recharge la liste depuis la base après une modification, puis notifie l'UI.
  Future<void> _reloadStudents() async {
    _students = await _repository.getStudents();
    notifyListeners();
  }
}

/// Bilan d'un import : ce qui a été ajouté et ce qui a été remplacé.
class ImportResult {
  const ImportResult({required this.added, required this.replaced});

  /// Portfolios qui n'existaient pas encore.
  final int added;

  /// Portfolios du même nom qui ont été écrasés par ceux du fichier.
  final int replaced;

  /// Nombre total de portfolios traités.
  int get total => added + replaced;
}

/// Levée quand on tente de créer (ou renommer vers) un nom déjà pris.
class DuplicatePortfolioNameException implements Exception {
  const DuplicatePortfolioNameException(this.fullName);

  /// Le nom en conflit.
  final String fullName;

  @override
  String toString() => 'Un portfolio nommé « $fullName » existe déjà.';
}
