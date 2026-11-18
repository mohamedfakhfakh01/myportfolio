// Tests de la sauvegarde JSON des portfolios : aller-retour complet et
// robustesse face à un fichier invalide.

import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/portfolio/domain/portfolio_backup.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

void main() {
  const student = Student(
    id: 7,
    fullName: 'Mohamed Fakhfakh',
    field: '3e année Licence Informatique',
    bio: 'Une bio',
    githubUsername: 'mohamedfakhfakh01',
    photoPath: '/tmp/photo.png',
    email: 'a@b.c',
    phone: '+216 24 098 402',
    linkedin: 'pseudo',
    location: 'Sfax',
    skills: [
      Skill(name: 'Dart', level: 80, category: SkillCategory.language),
      Skill(name: 'Git', category: SkillCategory.tool),
    ],
    projects: [
      Project(
        title: 'MyPortfolio',
        description: 'Application mobile',
        link: 'https://example.com',
        tags: ['Flutter', 'Dart'],
      ),
    ],
    experiences: [
      ExperienceEntry(
        title: 'Stage',
        organization: 'Tekru',
        period: 'Juin 2026',
        description: 'Développement web',
        kind: ExperienceKind.experience,
      ),
      ExperienceEntry(title: 'Licence', kind: ExperienceKind.education),
    ],
  );

  group('Sauvegarde JSON', () {
    test('aller-retour : tout le contenu est conservé', () {
      final restored = decodePortfolioBackup(encodePortfolioBackup([student]));
      expect(restored, hasLength(1));
      final s = restored.single;

      expect(s.fullName, 'Mohamed Fakhfakh');
      expect(s.field, '3e année Licence Informatique');
      expect(s.bio, 'Une bio');
      expect(s.githubUsername, 'mohamedfakhfakh01');
      expect(s.email, 'a@b.c');
      expect(s.phone, '+216 24 098 402');
      expect(s.linkedin, 'pseudo');
      expect(s.location, 'Sfax');

      expect(s.skills.map((k) => k.name), ['Dart', 'Git']);
      expect(s.skills.first.level, 80);
      expect(s.skills.first.category, SkillCategory.language);
      expect(s.skills.last.level, isNull);
      expect(s.skills.last.category, SkillCategory.tool);

      expect(s.projects.single.title, 'MyPortfolio');
      expect(s.projects.single.tags, ['Flutter', 'Dart']);
      expect(s.projects.single.link, 'https://example.com');

      expect(s.experiences.map((e) => e.title), ['Stage', 'Licence']);
      expect(s.experiences.first.kind, ExperienceKind.experience);
      expect(s.experiences.last.kind, ExperienceKind.education);
    });

    test('les identifiants ne sont pas exportés (réattribués à l\'import)', () {
      expect(encodePortfolioBackup([student]), isNot(contains('"id"')));
      expect(decodePortfolioBackup(encodePortfolioBackup([student])).single.id,
          isNull);
    });

    test('le fichier porte la version du format', () {
      expect(encodePortfolioBackup([student]), contains('"format": 1'));
      expect(backupFormatVersion, 1);
    });

    test('liste vide : sauvegarde valide sans portfolio', () {
      expect(decodePortfolioBackup(encodePortfolioBackup([])), isEmpty);
    });

    test('fichier illisible → FormatException', () {
      expect(() => decodePortfolioBackup('ceci n\'est pas du json'),
          throwsFormatException);
    });

    test('JSON valide mais sans portfolios → FormatException', () {
      expect(() => decodePortfolioBackup('{"format": 1}'),
          throwsFormatException);
    });

    test('champs manquants : valeurs par défaut, pas de plantage', () {
      final restored = decodePortfolioBackup(
        '{"students":[{"fullName":"Alice"}]}',
      );
      final s = restored.single;
      expect(s.fullName, 'Alice');
      expect(s.field, '');
      expect(s.skills, isEmpty);
      expect(s.projects, isEmpty);
      expect(s.experiences, isEmpty);
    });
  });
}
