import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Faux repository **avec état** en mémoire : il rejoue le comportement de la
/// base (insert/update/delete qui se reflètent ensuite dans getStudents) sans
/// sqflite, pour tester la logique CRUD du provider.
class _FakeRepo extends PortfolioRepository {
  _FakeRepo(List<Student> students) : _students = List<Student>.of(students);
  final List<Student> _students;
  int _nextId = 1000;

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<void> ensureDemoStudent() async {}

  @override
  Future<List<Student>> getStudents() async => List<Student>.of(_students);

  @override
  Future<void> deleteStudent(int id) async =>
      _students.removeWhere((s) => s.id == id);

  int _indexOf(int studentId) =>
      _students.indexWhere((s) => s.id == studentId);

  @override
  Future<int> insertProject(Project project, int studentId) async {
    final int i = _indexOf(studentId);
    final int id = _nextId++;
    final withId = Project(
      id: id,
      title: project.title,
      description: project.description,
      link: project.link,
      imagePath: project.imagePath,
      tags: project.tags,
    );
    _students[i] = _students[i]
        .copyWith(projects: [..._students[i].projects, withId]);
    return id;
  }

  @override
  Future<void> updateProject(Project project) async {
    for (int i = 0; i < _students.length; i++) {
      final projects = _students[i].projects;
      final int j = projects.indexWhere((p) => p.id == project.id);
      if (j != -1) {
        final updated = [...projects]..[j] = project;
        _students[i] = _students[i].copyWith(projects: updated);
        return;
      }
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    for (int i = 0; i < _students.length; i++) {
      if (_students[i].projects.any((p) => p.id == id)) {
        _students[i] = _students[i].copyWith(
          projects: _students[i].projects.where((p) => p.id != id).toList(),
        );
        return;
      }
    }
  }

  @override
  Future<int> insertSkill(Skill skill, int studentId) async {
    final int i = _indexOf(studentId);
    final int id = _nextId++;
    final withId = Skill(
      id: id,
      name: skill.name,
      level: skill.level,
      category: skill.category,
    );
    _students[i] =
        _students[i].copyWith(skills: [..._students[i].skills, withId]);
    return id;
  }

  @override
  Future<int> insertExperience(ExperienceEntry entry, int studentId) async {
    final int i = _indexOf(studentId);
    final int id = _nextId++;
    final withId = ExperienceEntry(
      id: id,
      title: entry.title,
      organization: entry.organization,
      period: entry.period,
      description: entry.description,
      kind: entry.kind,
    );
    _students[i] = _students[i]
        .copyWith(experiences: [..._students[i].experiences, withId]);
    return id;
  }

  @override
  Future<int> insertStudent(Student student) async {
    final int id = _nextId++;
    // La vraie base n'insère QUE la ligne étudiant ; les compétences, le
    // parcours et les projets sont insérés ensuite par le provider.
    _students.add(student.copyWith(
      id: id,
      skills: const [],
      projects: const [],
      experiences: const [],
    ));
    return id;
  }
}

void main() {
  group('PortfolioProvider', () {
    test('load() charge les étudiants depuis le repository', () async {
      final provider = PortfolioProvider(
        repository: _FakeRepo([
          const Student(id: 1, fullName: 'Alice Martin', field: 'Info'),
          const Student(id: 2, fullName: 'Bob Durand', field: 'Info'),
        ]),
      );
      await pumpEventQueue();

      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.students, hasLength(2));
      expect(provider.studentById(1).fullName, 'Alice Martin');
    });

    test('deleteStudent() retire l\'étudiant et rafraîchit la liste', () async {
      final provider = PortfolioProvider(
        repository: _FakeRepo([
          const Student(id: 1, fullName: 'Alice Martin', field: 'Info'),
          const Student(id: 2, fullName: 'Bob Durand', field: 'Info'),
        ]),
      );
      await pumpEventQueue();

      await provider.deleteStudent(1);

      expect(provider.students, hasLength(1));
      expect(provider.students.first.id, 2);
    });

    group('CRUD projets', () {
      Future<PortfolioProvider> makeProvider() async {
        final provider = PortfolioProvider(
          repository: _FakeRepo([
            const Student(id: 1, fullName: 'Alice', field: 'Info'),
          ]),
        );
        await pumpEventQueue();
        return provider;
      }

      test('addProject ajoute le projet et conserve ses technologies',
          () async {
        final provider = await makeProvider();

        await provider.addProject(
          1,
          const Project(
            title: 'App',
            description: 'Desc',
            tags: ['Flutter', 'Dart'],
          ),
        );

        final projects = provider.studentById(1).projects;
        expect(projects, hasLength(1));
        expect(projects.first.title, 'App');
        expect(projects.first.tags, ['Flutter', 'Dart']);
        expect(projects.first.id, isNotNull);
      });

      test('updateProject modifie le projet existant', () async {
        final provider = await makeProvider();
        await provider.addProject(
          1,
          const Project(title: 'Avant', description: 'D'),
        );
        final int projectId = provider.studentById(1).projects.first.id!;

        await provider.updateProject(
          Project(id: projectId, title: 'Après', description: 'D2'),
        );

        final projects = provider.studentById(1).projects;
        expect(projects, hasLength(1));
        expect(projects.first.title, 'Après');
        expect(projects.first.description, 'D2');
      });

      test('deleteProject retire le projet', () async {
        final provider = await makeProvider();
        await provider.addProject(
          1,
          const Project(title: 'À supprimer', description: 'D'),
        );
        final int projectId = provider.studentById(1).projects.first.id!;

        await provider.deleteProject(projectId);

        expect(provider.studentById(1).projects, isEmpty);
      });
    });

    test('addSkill ajoute une compétence à l\'étudiant', () async {
      final provider = PortfolioProvider(
        repository: _FakeRepo([
          const Student(id: 1, fullName: 'Alice', field: 'Info'),
        ]),
      );
      await pumpEventQueue();

      await provider.addSkill(
        1,
        const Skill(name: 'Flutter', level: 80, category: SkillCategory.framework),
      );

      final skills = provider.studentById(1).skills;
      expect(skills, hasLength(1));
      expect(skills.first.name, 'Flutter');
      expect(skills.first.level, 80);
    });

    test('addStudent crée un étudiant avec compétences, parcours et projets',
        () async {
      final provider = PortfolioProvider(repository: _FakeRepo([]));
      await pumpEventQueue();

      await provider.addStudent(
        const Student(
          fullName: 'Nouveau Profil',
          field: 'Informatique',
          skills: [Skill(name: 'Dart', category: SkillCategory.language)],
          experiences: [ExperienceEntry(title: 'Stage')],
        ),
        projects: const [Project(title: 'Projet', description: 'D')],
      );

      expect(provider.students, hasLength(1));
      final created = provider.students.first;
      expect(created.id, isNotNull);
      expect(created.fullName, 'Nouveau Profil');
      expect(created.skills.map((s) => s.name), ['Dart']);
      expect(created.experiences.map((e) => e.title), ['Stage']);
      expect(created.projects.map((p) => p.title), ['Projet']);
    });
  });
}
