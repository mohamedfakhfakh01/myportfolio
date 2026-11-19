import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:myportfolio/app/theme/app_colors.dart';
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

/// Texte du PDF, mot par mot, dans l'ordre d'écriture. Le PDF est généré
/// **non compressé** : chaque mot y figure en clair sous la forme `[(mot)]TJ`.
Future<String> _pdfWords(Student student, AppLocalizations l) async {
  final bytes = await buildPortfolioPdf(student, l, compress: false);
  final String raw = latin1.decode(bytes);
  return RegExp(r'\[\(((?:\\.|[^\\)])*)\)\]TJ')
      .allMatches(raw)
      .map((m) => m.group(1)!.replaceAllMapped(
            RegExp(r'\\(.)'),
            (e) => e.group(1)!,
          ))
      .join(' ');
}

/// Couleurs de remplissage utilisées dans le PDF, en « #RRGGBB ». Le PDF non
/// compressé les écrit en clair : `0.05882 0.0902 0.16471 rg` = #0F172A.
Future<Set<String>> _fillColors(Student student, AppLocalizations l) async {
  final String raw = latin1.decode(
    await buildPortfolioPdf(student, l, compress: false),
  );
  String hex(String v) =>
      (double.parse(v) * 255).round().toRadixString(16).padLeft(2, '0');
  return RegExp(r'([\d.]+) ([\d.]+) ([\d.]+) rg')
      .allMatches(raw)
      .map((m) =>
          '#${hex(m.group(1)!)}${hex(m.group(2)!)}${hex(m.group(3)!)}'
              .toUpperCase())
      .toSet();
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

    group('caractères hors Latin-1 (police Helvetica)', () {
      test('pdfSafeText remplace la ponctuation typographique', () {
        expect(pdfSafeText('Informatique — IIT Sfax'),
            'Informatique - IIT Sfax');
        expect(pdfSafeText('Juin – Juillet 2026'), 'Juin - Juillet 2026');
        // Apostrophe et guillemets « intelligents » du clavier iOS.
        expect(pdfSafeText('l’IIT, “Flutter”'), 'l\'IIT, "Flutter"');
        expect(pdfSafeText('etc…'), 'etc...');
        expect(pdfSafeText('cœur, Œuvre'), 'coeur, OEuvre');
        expect(pdfSafeText('• React → Vue'), '· React -> Vue');
        expect(pdfSafeText('10 €'), '10 EUR');
        // Espace fine insécable (avant « ! ? ; ») → espace insécable Latin-1.
        expect(pdfSafeText('Bravo\u202F!'), 'Bravo\u00A0!');
      });

      test('pdfSafeText garde les accents et retire l\'inaffichable', () {
        const latin1 = 'Étudiante à Sfax : élève, ça, « citation », Ñ, ß, °, ·';
        expect(pdfSafeText(latin1), latin1);
        // Émoji et autres écritures : la police ne peut pas les dessiner.
        expect(pdfSafeText('Flutter 🚀'), 'Flutter ');
        expect(pdfSafeText(''), '');
      });

      test('aucun caractère perdu en silence avec les vraies données',
          () async {
        // Données reprises de sample_portfolio_data.dart (« — » et « – »).
        const s = Student(
          fullName: 'Mohamed Fakhfakh',
          field: '3e année Licence Informatique — IIT Sfax',
          bio: 'Passionné de mobile… l’app « MyPortfolio ».',
          skills: [Skill(name: 'C# — .NET', level: 70)],
          projects: [
            Project(
              title: 'Al Seniour — Restaurant',
              description: 'Site – réservation “en ligne”.',
              tags: ['Laravel — PHP'],
            ),
          ],
        );
        final List<String> logs = [];
        final bytes = await runZoned(
          () => buildPortfolioPdf(s, l),
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) => logs.add(line),
          ),
        );
        _expectValidPdf(bytes);
        // La bibliothèque `pdf` signale chaque caractère qu'elle saute.
        expect(
          logs.where((m) => m.contains('Unable to find a font')),
          isEmpty,
        );
      });
    });

    group('contenu du CV', () {
      const Student cv = Student(
        fullName: 'Alice Martin',
        field: 'Informatique',
        email: 'alice@example.com',
        phone: '+216 11 222 333',
        linkedin: 'linkedin.com/in/alice',
        location: 'Sfax, Tunisie',
        githubUsername: 'alice',
        skills: [Skill(name: 'Flutter', level: 80)],
        projects: [Project(title: 'MyPortfolio', description: 'Appli.')],
        experiences: [
          ExperienceEntry(
            title: 'Stagiaire développeur',
            organization: 'Tekru Technologies',
            period: 'Juin – Juillet 2026',
            description: 'Application Laravel.',
          ),
          ExperienceEntry(
            title: 'Licence Informatique',
            organization: 'IIT Sfax',
            period: '2024 – 2027',
            kind: ExperienceKind.education,
          ),
        ],
      );

      test('coordonnées : e-mail, téléphone, ville, LinkedIn, GitHub',
          () async {
        final String t = await _pdfWords(cv, l);
        expect(t, contains('alice@example.com'));
        expect(t, contains('+216 11 222 333'));
        expect(t, contains('Sfax, Tunisie'));
        expect(t, contains('linkedin.com/in/alice'));
        expect(t, contains('github.com/alice'));
      });

      test('parcours : expériences et formations, avec détails', () async {
        final String t = await _pdfWords(cv, l);
        expect(t, contains('EXPÉRIENCE'));
        expect(t, contains('Stagiaire développeur'));
        expect(t, contains('Tekru Technologies'));
        expect(t, contains('Juin - Juillet 2026')); // « – » remplacé
        expect(t, contains('Application Laravel.'));
        expect(t, contains('FORMATION'));
        expect(t, contains('Licence Informatique'));
        expect(t, contains('IIT Sfax'));
        expect(t, contains('2024 - 2027'));
      });

      test('ordre des sections identique à la page profil', () async {
        final String t = await _pdfWords(cv, l);
        final order = ['COMPÉTENCES', 'PROJETS', 'EXPÉRIENCE', 'FORMATION']
            .map(t.indexOf)
            .toList();
        expect(order, everyElement(greaterThanOrEqualTo(0)));
        expect(order, orderedEquals([...order]..sort()));
      });

      test('rien d\'inventé : sans données, ni contact ni parcours', () async {
        final String t = await _pdfWords(
          const Student(fullName: 'Bob', field: 'Info', email: '   '),
          l,
        );
        expect(t, isNot(contains('@')));
        expect(t, isNot(contains('EXPÉRIENCE')));
        expect(t, isNot(contains('FORMATION')));
        expect(t, isNot(contains('GitHub')));
      });

      test('expérience seule : pas de section Formation vide', () async {
        final String t = await _pdfWords(
          const Student(
            fullName: 'Bob',
            field: 'Info',
            experiences: [ExperienceEntry(title: 'Stage')],
          ),
          l,
        );
        expect(t, contains('EXPÉRIENCE'));
        expect(t, isNot(contains('FORMATION')));
      });
    });

    group('couleurs (identité de l\'app)', () {
      // Le thème de l'app est un état global : on le remet tel qu'au démarrage.
      tearDown(() => AppColors.applyBrightness(Brightness.dark));

      test('palette indigo de l\'app, plus l\'ancien bleu', () async {
        final colors = await _fillColors(complet, l);
        expect(colors, contains('#4F46E5')); // AppColors.primary
        expect(colors, contains('#0F172A')); // texte principal (clair)
        expect(colors, isNot(contains('#3B82F6'))); // ancien bleu
        expect(colors, isNot(contains('#2563EB'))); // ancien bleu foncé
      });

      test('même rendu que l\'app soit en thème clair ou sombre', () async {
        // Un PDF s'imprime sur papier blanc : en thème sombre, il ne doit
        // surtout pas reprendre le texte presque blanc de l'écran.
        AppColors.applyBrightness(Brightness.light);
        final clair = await _fillColors(complet, l);
        AppColors.applyBrightness(Brightness.dark);
        final sombre = await _fillColors(complet, l);
        expect(sombre, clair);
        expect(sombre, contains('#0F172A')); // texte foncé, même en sombre
      });
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
