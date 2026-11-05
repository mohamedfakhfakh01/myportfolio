// Tests unitaires des modèles de données.
//
// Ils vérifient la logique « pure » (conversion objet ↔ Map, calculs) sans
// base de données ni interface → ils s'exécutent très vite avec `flutter test`.

import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/github/data/github_repo.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

void main() {
  group('Skill', () {
    test('toMap puis fromMap conserve les valeurs', () {
      const skill = Skill(id: 1, name: 'Flutter', level: 70);
      final restored = Skill.fromMap(skill.toMap());
      expect(restored.id, 1);
      expect(restored.name, 'Flutter');
      expect(restored.level, 70);
    });

    test('le niveau peut être null', () {
      const skill = Skill(name: 'Dart');
      expect(skill.level, isNull);
      expect(Skill.fromMap(skill.toMap()).level, isNull);
    });
  });

  group('Project', () {
    test('toMap puis fromMap conserve les valeurs', () {
      const project = Project(
        id: 2,
        title: 'MyPortfolio',
        description: 'Application Flutter',
        link: 'https://example.com',
      );
      final restored = Project.fromMap(project.toMap());
      expect(restored.title, 'MyPortfolio');
      expect(restored.description, 'Application Flutter');
      expect(restored.link, 'https://example.com');
    });

    test('le lien peut être null', () {
      const project = Project(title: 'Titre', description: 'Desc');
      expect(Project.fromMap(project.toMap()).link, isNull);
    });

    test('les technologies sont conservées (round-trip JSON)', () {
      const project = Project(
        title: 'Projet',
        description: 'Desc',
        tags: ['Flutter', 'Dart', 'Firebase'],
      );
      final restored = Project.fromMap(project.toMap());
      expect(restored.tags, ['Flutter', 'Dart', 'Firebase']);
    });

    test('technologies avec caractères spéciaux (C#, ASP.NET, Node.js)', () {
      const project = Project(
        title: 'Projet',
        description: 'Desc',
        tags: ['C#', 'ASP.NET MVC', 'Node.js'],
      );
      final restored = Project.fromMap(project.toMap());
      expect(restored.tags, ['C#', 'ASP.NET MVC', 'Node.js']);
    });

    test('tags par défaut : liste vide quand non renseignés', () {
      const project = Project(title: 'Titre', description: 'Desc');
      expect(project.tags, isEmpty);
      expect(Project.fromMap(project.toMap()).tags, isEmpty);
    });

    test('fromMap tolérant : colonne tags absente ou null → liste vide', () {
      final sansColonne = Project.fromMap({
        'id': 1,
        'title': 'T',
        'description': 'D',
      });
      expect(sansColonne.tags, isEmpty);

      final tagsNull = Project.fromMap({
        'id': 1,
        'title': 'T',
        'description': 'D',
        'tags': null,
      });
      expect(tagsNull.tags, isEmpty);
    });

    test('fromMap tolérant : JSON invalide → liste vide (ne plante pas)', () {
      final project = Project.fromMap({
        'id': 1,
        'title': 'T',
        'description': 'D',
        'tags': 'pas du json',
      });
      expect(project.tags, isEmpty);
    });

    test('fromMap : entrées vides dans les tags sont ignorées', () {
      final project = Project.fromMap({
        'id': 1,
        'title': 'T',
        'description': 'D',
        'tags': '["Flutter", "", "  ", "Dart"]',
      });
      expect(project.tags, ['Flutter', 'Dart']);
    });
  });

  group('Student', () {
    test('initials : prénom + nom → deux lettres', () {
      const student = Student(fullName: 'Mohamed Fakhfakh', field: '2e année');
      expect(student.initials, 'MF');
    });

    test('initials : un seul mot → une lettre', () {
      const student = Student(fullName: 'Houssain', field: 'x');
      expect(student.initials, 'H');
    });

    test('initials : nom vide → ?', () {
      const student = Student(fullName: '   ', field: 'x');
      expect(student.initials, '?');
    });

    test('copyWith ne remplace que les champs fournis', () {
      const student = Student(id: 1, fullName: 'A', field: 'f', bio: 'ancienne');
      final updated = student.copyWith(bio: 'nouvelle');
      expect(updated.id, 1);
      expect(updated.fullName, 'A');
      expect(updated.bio, 'nouvelle');
    });

    test('fromMap : bio nulle devient une chaîne vide, listes vides', () {
      final student = Student.fromMap({
        'id': 3,
        'fullName': 'X Y',
        'field': 'Informatique',
        'bio': null,
        'githubUsername': 'xy',
      });
      expect(student.id, 3);
      expect(student.bio, '');
      expect(student.githubUsername, 'xy');
      expect(student.skills, isEmpty);
      expect(student.projects, isEmpty);
    });
  });

  group('GithubRepo', () {
    test('fromJson lit les clés de l\'API GitHub', () {
      final repo = GithubRepo.fromJson({
        'name': 'myportfolio',
        'description': 'App',
        'language': 'Dart',
        'stargazers_count': 5,
        'html_url': 'https://github.com/x/myportfolio',
      });
      expect(repo.name, 'myportfolio');
      expect(repo.language, 'Dart');
      expect(repo.stars, 5);
      expect(repo.htmlUrl, contains('myportfolio'));
    });

    test('valeurs par défaut si champs absents', () {
      final repo = GithubRepo.fromJson({
        'name': 'r',
        'html_url': 'u',
      });
      expect(repo.stars, 0);
      expect(repo.description, isNull);
      expect(repo.language, isNull);
    });
  });
}
