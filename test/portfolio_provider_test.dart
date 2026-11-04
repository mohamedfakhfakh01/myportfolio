import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Faux repository en mémoire : on remplace les accès à la base par une simple
/// liste, pour tester la logique du provider sans sqflite.
class _FakeRepo extends PortfolioRepository {
  _FakeRepo(this._students);
  final List<Student> _students;

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<void> ensureDemoStudent() async {}

  @override
  Future<List<Student>> getStudents() async => List<Student>.of(_students);

  @override
  Future<void> deleteStudent(int id) async =>
      _students.removeWhere((s) => s.id == id);
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
  });
}
