import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Point d'accès unique à la base de données locale (SQLite via `sqflite`).
///
/// Cette classe ouvre la base **une seule fois** et crée les tables au premier
/// lancement. On l'utilise via `AppDatabase.instance.database`.
///
/// Analogie : c'est le « gardien du garde-manger ». Tout le monde passe par lui
/// pour ouvrir la réserve, il n'y a qu'une seule porte.
class AppDatabase {
  // Constructeur privé + instance unique = patron « singleton ».
  // Garantit une seule connexion à la base dans toute l'application.
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  /// La connexion ouverte, mise en cache après la première ouverture.
  Database? _db;

  /// Renvoie la base, en l'ouvrant la première fois seulement.
  /// `Future` = résultat asynchrone (l'ouverture prend un petit moment).
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  /// Ouvre (ou crée) le fichier de base de données.
  Future<Database> _open() async {
    // Dossier standard des bases sur l'appareil + nom du fichier.
    final String folder = await getDatabasesPath();
    final String path = join(folder, 'myportfolio.db');

    return openDatabase(
      path,
      version: 5,
      // Active le respect des clés étrangères (désactivé par défaut en SQLite).
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // Appelé UNE fois, à la toute première création de la base.
      onCreate: _createTables,
      // Appelé quand la version augmente : fait évoluer une base déjà installée.
      onUpgrade: _onUpgrade,
    );
  }

  /// Crée les 3 tables liées : students, skills, projects.
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        field TEXT NOT NULL,
        bio TEXT,
        githubUsername TEXT,
        photoPath TEXT,
        email TEXT,
        phone TEXT,
        linkedin TEXT,
        location TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE skills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        name TEXT NOT NULL,
        level INTEGER,
        category TEXT,
        FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        link TEXT,
        FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE experiences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        title TEXT NOT NULL,
        organization TEXT,
        period TEXT,
        description TEXT,
        kind TEXT,
        FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Fait évoluer une base déjà installée vers une version plus récente, sans
  /// perdre les données existantes. Appelé automatiquement si la version du
  /// fichier sur l'appareil est inférieure à celle du code.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2 : ajout de la colonne de la photo de profil.
      await db.execute('ALTER TABLE students ADD COLUMN photoPath TEXT');
    }
    if (oldVersion < 3) {
      // v3 : ajout de la catégorie des compétences (langage, framework…).
      await db.execute('ALTER TABLE skills ADD COLUMN category TEXT');
    }
    if (oldVersion < 4) {
      // v4 : ajout de la table du parcours (expériences et formations).
      await db.execute('''
        CREATE TABLE experiences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          studentId INTEGER NOT NULL,
          title TEXT NOT NULL,
          organization TEXT,
          period TEXT,
          description TEXT,
          kind TEXT,
          FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      // v5 : coordonnées de contact (e-mail, téléphone, LinkedIn, localisation).
      await db.execute('ALTER TABLE students ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE students ADD COLUMN phone TEXT');
      await db.execute('ALTER TABLE students ADD COLUMN linkedin TEXT');
      await db.execute('ALTER TABLE students ADD COLUMN location TEXT');
    }
  }
}
