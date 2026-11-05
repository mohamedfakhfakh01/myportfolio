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
    await _repository.updateStudent(student);
    await _reloadStudents();
  }

  /// Crée un nouvel étudiant (nouveau portfolio), éventuellement avec des
  /// projets saisis dès la création.
  Future<void> addStudent(
    Student student, {
    List<Project> projects = const [],
  }) async {
    // On insère d'abord l'étudiant pour obtenir son id, puis ses compétences
    // et ses projets.
    final int studentId = await _repository.insertStudent(student);
    for (final skill in student.skills) {
      await _repository.insertSkill(skill, studentId);
    }
    for (final project in projects) {
      await _repository.insertProject(project, studentId);
    }
    await _reloadStudents();
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
