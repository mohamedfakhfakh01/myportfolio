import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:myportfolio/features/portfolio/services/portfolio_pdf.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Un vrai PDF commence toujours par la signature « %PDF- » et se termine
/// par « %%EOF » : c'est ce qui permet à un lecteur de l'ouvrir.
void _expectValidPdf(List<int> bytes) {
  expect(bytes, isNotEmpty);
  expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  final String tail = String.fromCharCodes(bytes.skip(bytes.length - 32));
  expect(tail, contains('%%EOF'));
}

void main() {
  // Textes français générés par `flutter gen-l10n` (pas besoin d'écran).
  final AppLocalizations l = lookupAppLocalizations(const Locale('fr'));

  const Student complet = Student(
    id: 1,
    fullName: 'Alice Martin',
    field: '2e année informatique',
    bio: 'Étudiante passionnée par le mobile — « accents » compris.',
    email: 'alice@example.com',
    skills: [
      Skill(name: 'Flutter', level: 80, category: SkillCategory.framework),
      Skill(name: 'Dart', category: SkillCategory.language), // sans niveau
    ],
    projects: [
      Project(
        title: 'MyPortfolio',
        description: 'Application de portfolio.',
        tags: ['Flutter', 'SQLite'],
      ),
      Project(title: 'Sans technos', description: 'Projet minimal.'),
    ],
    experiences: [ExperienceEntry(title: 'Stage')],
  );

  group('buildPortfolioPdf', () {
    test('profil complet → un PDF valide', () async {
      _expectValidPdf(await buildPortfolioPdf(complet, l));
    });

    test('profil minimal (nom + filière seulement) → un PDF valide', () async {
      const minimal = Student(fullName: 'Bob', field: 'Info');
      _expectValidPdf(await buildPortfolioPdf(minimal, l));
    });

    test('les sections vides sont omises : PDF plus léger', () async {
      const minimal = Student(fullName: 'Alice Martin', field: 'Info');
      final full = await buildPortfolioPdf(complet, l);
      final empty = await buildPortfolioPdf(minimal, l);
      expect(full.length, greaterThan(empty.length));
    });

    test('beaucoup de projets → plusieurs pages, sans erreur', () async {
      final long = complet.copyWith(
        projects: [
          for (int i = 0; i < 40; i++)
            Project(
              title: 'Projet $i',
              description: 'Description assez longue du projet numéro $i. ' * 3,
              tags: const ['Flutter', 'Dart'],
            ),
        ],
      );
      final bytes = await buildPortfolioPdf(long, l);
      _expectValidPdf(bytes);
      // Chaque page du PDF est un objet « /Type /Page » (non compressé).
      final int pages =
          RegExp(r'/Type\s*/Page[^s]').allMatches(String.fromCharCodes(bytes)).length;
      expect(pages, greaterThan(1));
    });

    group('photo de profil', () {
      late Directory tmp;
      setUp(() => tmp = Directory.systemTemp.createTempSync('pdf_test_'));
      tearDown(() => tmp.deleteSync(recursive: true));

      test('fichier introuvable → ignoré, PDF quand même produit', () async {
        final s = complet.copyWith(photoPath: '${tmp.path}/absente.jpg');
        _expectValidPdf(await buildPortfolioPdf(s, l));
      });

      test('vraie image PNG → incluse, PDF plus lourd', () async {
        final file = File('${tmp.path}/photo.png')
          ..writeAsBytesSync(img.encodePng(img.Image(width: 64, height: 64)));
        final sans = await buildPortfolioPdf(complet, l);
        final avec =
            await buildPortfolioPdf(complet.copyWith(photoPath: file.path), l);
        _expectValidPdf(avec);
        expect(avec.length, greaterThan(sans.length));
      });

      test('fichier corrompu (pas une image) → ignoré, pas de plantage',
          () async {
        final file = File('${tmp.path}/corrompue.jpg')
          ..writeAsStringSync('ceci n\'est pas une image');
        final s = complet.copyWith(photoPath: file.path);
        _expectValidPdf(await buildPortfolioPdf(s, l));
      });
    });
  });
}
