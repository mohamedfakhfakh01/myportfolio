// Tests du calcul de complétion du portfolio.
//
// C'est de la logique pure (pas d'interface, pas de base) : on vérifie que le
// score reflète exactement les champs renseignés, sans rien inventer.

import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/portfolio/domain/profile_completion.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

void main() {
  group('profileCompletion', () {
    test('profil vide : 0 critère rempli, 0 %', () {
      const student = Student(fullName: 'Vide', field: 'Info');
      final c = profileCompletion(student);
      expect(c.done, 0);
      expect(c.total, 11);
      expect(c.percent, 0);
      expect(c.fraction, 0);
    });

    test('profil complet : tous les critères, 100 %', () {
      const student = Student(
        fullName: 'Complet',
        field: 'Info',
        bio: 'Une bio',
        githubUsername: 'octocat',
        photoPath: '/tmp/photo.png',
        email: 'a@b.c',
        phone: '+216 00 000 000',
        linkedin: 'pseudo',
        location: 'Sfax',
        skills: [Skill(name: 'Dart')],
        projects: [Project(title: 'P', description: 'D')],
        experiences: [
          ExperienceEntry(title: 'Stage', kind: ExperienceKind.experience),
          ExperienceEntry(title: 'Licence', kind: ExperienceKind.education),
        ],
      );
      final c = profileCompletion(student);
      expect(c.done, 11);
      expect(c.percent, 100);
      expect(c.fraction, 1);
    });

    test('les champs faits uniquement d\'espaces ne comptent pas', () {
      const student = Student(
        fullName: 'Espaces',
        field: 'Info',
        bio: '   ',
        email: '  ',
      );
      expect(profileCompletion(student).done, 0);
    });

    test('expérience et formation comptent séparément', () {
      const avecStageSeul = Student(
        fullName: 'X',
        field: 'Info',
        experiences: [
          ExperienceEntry(title: 'Stage', kind: ExperienceKind.experience),
        ],
      );
      expect(profileCompletion(avecStageSeul).done, 1);

      const avecLesDeux = Student(
        fullName: 'X',
        field: 'Info',
        experiences: [
          ExperienceEntry(title: 'Stage', kind: ExperienceKind.experience),
          ExperienceEntry(title: 'Licence', kind: ExperienceKind.education),
        ],
      );
      expect(profileCompletion(avecLesDeux).done, 2);
    });

    test('profil vide : tous les critères sont listés comme manquants', () {
      const student = Student(fullName: 'Vide', field: 'Info');
      final c = profileCompletion(student);
      expect(c.missing.length, 11);
      expect(c.isComplete, isFalse);
      // L'ordre d'affichage est stable : la photo vient en premier.
      expect(c.missing.first, ProfileCriterion.photo);
    });

    test('profil complet : aucun manquant', () {
      const student = Student(
        fullName: 'Complet',
        field: 'Info',
        bio: 'Une bio',
        githubUsername: 'octocat',
        photoPath: '/tmp/photo.png',
        email: 'a@b.c',
        phone: '+216 00 000 000',
        linkedin: 'pseudo',
        location: 'Sfax',
        skills: [Skill(name: 'Dart')],
        projects: [Project(title: 'P', description: 'D')],
        experiences: [
          ExperienceEntry(title: 'Stage', kind: ExperienceKind.experience),
          ExperienceEntry(title: 'Licence', kind: ExperienceKind.education),
        ],
      );
      final c = profileCompletion(student);
      expect(c.missing, isEmpty);
      expect(c.isComplete, isTrue);
    });

    test('ne liste QUE ce qui manque vraiment', () {
      const student = Student(
        fullName: 'Partiel',
        field: 'Info',
        bio: 'Une bio',
        email: 'a@b.c',
        skills: [Skill(name: 'Dart')],
      );
      final c = profileCompletion(student);
      // Renseignés : bio, email, compétences → absents de la liste.
      expect(c.missing, isNot(contains(ProfileCriterion.bio)));
      expect(c.missing, isNot(contains(ProfileCriterion.email)));
      expect(c.missing, isNot(contains(ProfileCriterion.skills)));
      // Manquants : photo, téléphone, projets, formation…
      expect(c.missing, contains(ProfileCriterion.photo));
      expect(c.missing, contains(ProfileCriterion.phone));
      expect(c.missing, contains(ProfileCriterion.projects));
      expect(c.missing, contains(ProfileCriterion.education));
      expect(c.done + c.missing.length, c.total);
    });

    test('le pourcentage est arrondi correctement', () {
      // 3 critères sur 11 → 27,27 % → 27 %
      const student = Student(
        fullName: 'X',
        field: 'Info',
        bio: 'bio',
        email: 'a@b.c',
        phone: '123',
      );
      final c = profileCompletion(student);
      expect(c.done, 3);
      expect(c.percent, 27);
    });
  });
}
