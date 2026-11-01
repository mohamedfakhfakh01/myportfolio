import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/student.dart';
import 'sample_portfolio_data.dart';

/// Accès aux données des portfolios dans la base SQLite.
///
/// C'est la « cuisine » : la seule partie du code qui écrit/lit réellement la
/// base. Le reste de l'app (Provider, écrans) passe par ses méthodes et ignore
/// le SQL. Toutes les méthodes sont **asynchrones** (`Future`) car la base
/// répond « plus tard ».
class PortfolioRepository {
  /// Raccourci vers la connexion unique à la base.
  Future<Database> get _db => AppDatabase.instance.database;

  // ---------------------------------------------------------------------------
  // LECTURE
  // ---------------------------------------------------------------------------

  /// Récupère tous les étudiants, chacun avec ses compétences et ses projets.
  ///
  /// On lit d'abord la table `students`, puis pour chaque étudiant on lit ses
  /// compétences et projets (tables liées par `studentId`), et on assemble le
  /// tout avec `copyWith`.
  Future<List<Student>> getStudents() async {
    final db = await _db;
    final List<Map<String, Object?>> rows =
        await db.query('students', orderBy: 'id');

    final List<Student> students = [];
    for (final row in rows) {
      final Student base = Student.fromMap(row);
      final int studentId = base.id!;

      final skillRows = await db
          .query('skills', where: 'studentId = ?', whereArgs: [studentId]);
      final projectRows = await db
          .query('projects', where: 'studentId = ?', whereArgs: [studentId]);

      students.add(
        base.copyWith(
          skills: skillRows.map(Skill.fromMap).toList(),
          projects: projectRows.map(Project.fromMap).toList(),
        ),
      );
    }
    return students;
  }

  // ---------------------------------------------------------------------------
  // SEED (remplissage initial)
  // ---------------------------------------------------------------------------

  /// Remplit la base avec les données de départ **uniquement si elle est vide**
  /// (premier lancement). Évite de dupliquer les données aux lancements suivants.
  Future<void> seedIfEmpty() async {
    final db = await _db;
    final int count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM students'),
        ) ??
        0;
    if (count > 0) return; // déjà des données → on ne refait pas le seed

    for (final student in sampleStudents) {
      // On laisse la base attribuer l'id (AUTOINCREMENT) → on retire l'id local.
      final studentMap = student.toMap()..remove('id');
      final int studentId = await db.insert('students', studentMap);

      for (final skill in student.skills) {
        await insertSkill(skill, studentId);
      }
      for (final project in student.projects) {
        await insertProject(project, studentId);
      }
    }
  }

  /// Insère l'étudiant de **démonstration** s'il n'est pas déjà présent.
  ///
  /// Contrairement à [seedIfEmpty] (qui ne s'exécute qu'une fois, sur base
  /// vide), cette méthode est **idempotente** : elle peut ajouter le profil
  /// démo à une base déjà remplie, mais seulement s'il manque — donc pas de
  /// doublon à chaque lancement. Les données viennent de [sampleStudents]
  /// (une seule source de vérité : on ne les réécrit pas ici).
  Future<void> ensureDemoStudent() async {
    final db = await _db;
    // Le profil démo est l'entrée de sampleStudents reconnue par son nom.
    final Student demo = sampleStudents.firstWhere(
      (s) => s.fullName == 'Portfolio Démo',
    );
    // Déjà présent ? (recherche par nom) → on ne refait rien.
    final existing = await db.query(
      'students',
      where: 'fullName = ?',
      whereArgs: [demo.fullName],
      limit: 1,
    );
    if (existing.isNotEmpty) return;
    // Sinon on l'insère avec ses compétences et projets (comme le seed).
    final studentMap = demo.toMap()..remove('id');
    final int studentId = await db.insert('students', studentMap);
    for (final skill in demo.skills) {
      await insertSkill(skill, studentId);
    }
    for (final project in demo.projects) {
      await insertProject(project, studentId);
    }
  }

  // ---------------------------------------------------------------------------
  // CRUD — COMPÉTENCES
  // ---------------------------------------------------------------------------

  Future<int> insertSkill(Skill skill, int studentId) async {
    final db = await _db;
    final map = skill.toMap()..remove('id');
    map['studentId'] = studentId;
    return db.insert('skills', map);
  }

  Future<void> updateSkill(Skill skill) async {
    final db = await _db;
    await db.update('skills', skill.toMap(),
        where: 'id = ?', whereArgs: [skill.id]);
  }

  Future<void> deleteSkill(int id) async {
    final db = await _db;
    await db.delete('skills', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // CRUD — PROJETS
  // ---------------------------------------------------------------------------

  Future<int> insertProject(Project project, int studentId) async {
    final db = await _db;
    final map = project.toMap()..remove('id');
    map['studentId'] = studentId;
    return db.insert('projects', map);
  }

  Future<void> updateProject(Project project) async {
    final db = await _db;
    await db.update('projects', project.toMap(),
        where: 'id = ?', whereArgs: [project.id]);
  }

  Future<void> deleteProject(int id) async {
    final db = await _db;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // CRUD — PROFIL ÉTUDIANT
  // ---------------------------------------------------------------------------

  /// Met à jour les champs modifiables d'un étudiant (bio, filière, GitHub).
  Future<void> updateStudent(Student student) async {
    final db = await _db;
    await db.update('students', student.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
  }

  /// Insère un nouvel étudiant (nouveau portfolio) et renvoie son id.
  Future<int> insertStudent(Student student) async {
    final db = await _db;
    final map = student.toMap()..remove('id');
    return db.insert('students', map);
  }

  /// Supprime un étudiant. Grâce aux clés étrangères `ON DELETE CASCADE`,
  /// ses compétences et projets sont supprimés automatiquement.
  Future<void> deleteStudent(int id) async {
    final db = await _db;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }
}
