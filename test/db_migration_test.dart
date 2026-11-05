// Tests d'intégration de la base de données : on vérifie que les MIGRATIONS
// de schéma font évoluer une base existante sans perdre les données.
//
// On utilise `sqflite_common_ffi` pour exécuter un vrai SQLite sur la machine
// de test (hors appareil). Les callbacks de schéma (onConfigure / onCreate /
// onUpgrade) sont ceux de l'app, réutilisés tels quels.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:myportfolio/core/database/app_database.dart';
import 'package:myportfolio/shared/models/project.dart';

void main() {
  // Initialise le moteur SQLite natif pour l'environnement de test.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory tempDir;
  late String dbPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('mp_migration_test');
    dbPath = '${tempDir.path}/myportfolio_test.db';
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('Migration de la base', () {
    test(
        'v6 → v7 : ajoute la colonne tags SANS perdre les projets existants',
        () async {
      // 1) Base "ancienne" en v6 : table projects SANS colonne tags.
      final old = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 6,
          onConfigure: AppDatabase.onConfigure,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                studentId INTEGER NOT NULL,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                link TEXT,
                imagePath TEXT
              )
            ''');
          },
        ),
      );
      await old.insert('projects', {
        'studentId': 1,
        'title': 'Projet existant',
        'description': 'Créé en v6',
        'link': 'https://example.com',
        'imagePath': null,
      });
      await old.close();

      // 2) Réouverture en v7 : onUpgrade(6, 7) doit s'exécuter.
      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: AppDatabase.latestVersion,
          onConfigure: AppDatabase.onConfigure,
          onCreate: AppDatabase.onCreate,
          onUpgrade: AppDatabase.onUpgrade,
        ),
      );

      // Le projet créé en v6 est toujours là (pas de perte de données).
      final rows = await db.query('projects');
      expect(rows.length, 1);
      expect(rows.first['title'], 'Projet existant');

      // La colonne tags existe maintenant ; l'ancien projet a tags = NULL,
      // que le modèle interprète comme une liste vide (décodage tolérant).
      final migrated = Project.fromMap(rows.first);
      expect(migrated.tags, isEmpty);

      // On peut écrire puis relire des technologies sur la nouvelle colonne.
      const nouveau = Project(
        title: 'Nouveau',
        description: 'Avec technos',
        tags: ['Flutter', 'Dart'],
      );
      final nouveauMap = nouveau.toMap()..remove('id');
      nouveauMap['studentId'] = 2;
      await db.insert('projects', nouveauMap);
      final relu = await db.query('projects',
          where: 'title = ?', whereArgs: ['Nouveau']);
      expect(Project.fromMap(relu.first).tags, ['Flutter', 'Dart']);

      await db.close();
    });

    test('création fraîche en v7 : la table projects a la colonne tags',
        () async {
      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: AppDatabase.latestVersion,
          onConfigure: AppDatabase.onConfigure,
          onCreate: AppDatabase.onCreate,
          onUpgrade: AppDatabase.onUpgrade,
        ),
      );

      // Un étudiant est requis (clé étrangère) avant d'insérer un projet.
      final studentId = await db.insert('students', {
        'fullName': 'Test',
        'field': 'Info',
      });

      const project = Project(
        title: 'Projet v7',
        description: 'Desc',
        tags: ['C#', 'ASP.NET MVC'],
      );
      final projectMap = project.toMap()..remove('id');
      projectMap['studentId'] = studentId;
      await db.insert('projects', projectMap);

      final rows = await db.query('projects');
      expect(rows.length, 1);
      expect(Project.fromMap(rows.first).tags, ['C#', 'ASP.NET MVC']);

      await db.close();
    });
  });
}
