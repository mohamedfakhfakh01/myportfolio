import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/experience.dart';
import '../../../shared/models/project.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/student.dart';
import '../../../shared/utils/linkedin.dart';

// --- Palette du PDF (reprend les couleurs de l'app) ---
final PdfColor _primary = PdfColor.fromInt(0xFF3B82F6); // bleu principal
final PdfColor _primaryDark = PdfColor.fromInt(0xFF2563EB); // bleu foncé
final PdfColor _ink = PdfColor.fromInt(0xFF0F172A); // texte principal
final PdfColor _muted = PdfColor.fromInt(0xFF64748B); // texte secondaire
final PdfColor _track = PdfColor.fromInt(0xFFE2E8F0); // fond des barres
final PdfColor _cardBg = PdfColor.fromInt(0xFFF8FAFC); // fond des cartes projet
final PdfColor _chipBg = PdfColor.fromInt(0xFFDBEAFE); // fond des puces

/// Construit un **CV / portfolio en PDF** moderne à partir d'un [Student].
///
/// La bibliothèque `pdf` fournit des widgets (`pw.*`) proches de Flutter mais
/// qui décrivent une page imprimable. La police standard (Helvetica) gère les
/// accents français.
///
/// Ne contient que des données **réelles** de l'étudiant : les champs absents
/// (bio vide, niveau non renseigné…) sont simplement omis, rien n'est inventé.
///
/// [compress] à `false` laisse le texte lisible en clair dans le fichier : ne
/// sert qu'aux tests, qui vérifient ainsi ce que le PDF contient vraiment.
Future<Uint8List> buildPortfolioPdf(
  Student source,
  AppLocalizations l, {
  bool compress = true,
}) async {
  // Texte rendu « dessinable » une fois pour toutes, avant toute mise en page
  // (voir [pdfSafeText]) : aucun caractère ne disparaît en silence.
  final Student student = _pdfSafeStudent(source);
  final doc = pw.Document(compress: compress);
  final experiences = student.experiences
      .where((e) => e.kind == ExperienceKind.experience)
      .toList();
  final education = student.experiences
      .where((e) => e.kind == ExperienceKind.education)
      .toList();

  // Photo de profil (optionnelle) : seulement si le fichier existe vraiment.
  pw.MemoryImage? photo;
  final String? photoPath = student.photoPath;
  if (photoPath != null && File(photoPath).existsSync()) {
    try {
      photo = pw.MemoryImage(File(photoPath).readAsBytesSync());
    } catch (_) {
      photo = null;
    }
  }

  // Le contenu est une liste **à plat** de petits blocs : `MultiPage` ne coupe
  // une page qu'entre deux blocs. (Avant, les compétences formaient un seul
  // gros bloc, poussé en entier à la page suivante → page 1 à moitié vide.)
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero, // le bandeau coloré va bord à bord
      // Marge haute des pages suivantes (la 1re commence par le bandeau).
      header: (context) => pw.SizedBox(height: context.pageNumber == 1 ? 0 : 32),
      footer: (context) => _footer(context),
      build: (context) => [
        _header(student, photo),
        pw.SizedBox(height: 12),

        // --- À propos ---
        if (student.bio.isNotEmpty)
          ..._section(l.navAbout, [
            pw.Text(
              student.bio,
              style: pw.TextStyle(fontSize: 11, color: _ink, lineSpacing: 2),
            ),
          ]),

        // --- Compétences (barres de niveau, puces sinon) ---
        if (student.skills.isNotEmpty)
          ..._section(l.skills, _skillWidgets(student.skills)),

        // --- Projets (en cartes) ---
        if (student.projects.isNotEmpty)
          ..._section(l.projects, [
            for (final project in student.projects)
              _projectCard(project.title, project.description, project.tags),
          ]),

        // --- Parcours : même ordre que la page profil ---
        if (experiences.isNotEmpty)
          ..._section(l.experienceTitle, [
            for (final entry in experiences) _journeyEntry(entry),
          ]),
        if (education.isNotEmpty)
          ..._section(l.educationTitle, [
            for (final entry in education) _journeyEntry(entry),
          ]),
        pw.SizedBox(height: 12),
      ],
    ),
  );

  return doc.save();
}

/// Bandeau d'en-tête coloré : médaillon (photo ou initiales) + identité.
pw.Widget _header(Student student, pw.MemoryImage? photo) {
  // Coordonnées réellement renseignées (un champ vide ou blanc est omis).
  bool filled(String? v) => v != null && v.trim().isNotEmpty;
  final String? linkedin = student.linkedin;
  final String? github = student.githubUsername;
  final List<pw.Widget> contacts = [
    if (filled(student.email))
      _contactItem(student.email!.trim(), 'mailto:${student.email!.trim()}'),
    if (filled(student.phone)) _contactItem(student.phone!.trim()),
    if (filled(student.location)) _contactItem(student.location!.trim()),
    if (filled(linkedin))
      _contactItem(
        // Adresse lisible à l'impression : sans « https:// » ni « www. ».
        linkedinUrl(linkedin!).replaceFirst(RegExp(r'^https?://(www\.)?'), ''),
        linkedinUrl(linkedin),
      ),
    if (filled(github))
      _contactItem('github.com/${github!.trim()}',
          'https://github.com/${github.trim()}'),
  ];

  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(32),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [_primary, _primaryDark],
        begin: pw.Alignment.topLeft,
        end: pw.Alignment.bottomRight,
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 76,
          height: 76,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: _primaryDark,
            border: pw.Border.all(color: PdfColors.white, width: 2),
            image: photo != null
                ? pw.DecorationImage(image: photo, fit: pw.BoxFit.cover)
                : null,
          ),
          child: photo == null
              ? pw.Text(
                  student.initials,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                )
              : null,
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                student.fullName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                student.field,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                ),
              ),
              if (contacts.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 14,
                  runSpacing: 3,
                  children: contacts,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// Titre de section : petit carré coloré + libellé, sur une ligne soulignée.
pw.Widget _sectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(width: 10, height: 10, color: _primary),
            pw.SizedBox(width: 8),
            pw.Text(
              pdfSafeText(title.toUpperCase()),
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(height: 1, thickness: 1, color: _track),
      ],
    ),
  );
}

/// Section du PDF : marges latérales, et titre **attaché** au premier bloc
/// (jamais de titre seul en bas de page, son contenu étant sur la suivante).
List<pw.Widget> _section(String title, List<pw.Widget> blocks) {
  pw.Widget padded(pw.Widget child) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 32),
        child: child,
      );
  return [
    padded(
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [_sectionTitle(title), if (blocks.isNotEmpty) blocks.first],
        ),
      ),
    ),
    for (final block in blocks.skip(1)) padded(block),
  ];
}

/// Compétences : une barre par compétence avec niveau (chacune est un bloc
/// séparé, donc répartissable sur plusieurs pages), puis les puces des autres.
List<pw.Widget> _skillWidgets(List<Skill> skills) {
  final withLevel = skills.where((s) => s.level != null).toList();
  final withoutLevel = skills.where((s) => s.level == null).toList();
  return [
    for (final skill in withLevel) _skillWithBar(skill),
    if (withoutLevel.isNotEmpty)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final s in withoutLevel) _skillChip(s.name)],
        ),
      ),
  ];
}

/// Compétence avec son niveau : nom + pourcentage + barre de progression.
pw.Widget _skillWithBar(Skill skill) {
  final int level = skill.level!.clamp(0, 100);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 7),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(skill.name,
                style: pw.TextStyle(fontSize: 10, color: _ink)),
            pw.Text('$level%',
                style: pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
        pw.SizedBox(height: 3),
        _levelBar(level),
      ],
    ),
  );
}

/// Barre de progression dessinée à la main (part remplie / part vide).
pw.Widget _levelBar(int level) {
  final int v = level.clamp(0, 100);
  return pw.Container(
    height: 6,
    decoration: pw.BoxDecoration(
      color: _track,
      borderRadius: pw.BorderRadius.circular(3),
    ),
    child: pw.Row(
      children: [
        if (v > 0)
          pw.Expanded(
            flex: v,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: _primary,
                borderRadius: pw.BorderRadius.circular(3),
              ),
            ),
          ),
        if (v < 100) pw.Expanded(flex: 100 - v, child: pw.SizedBox()),
      ],
    ),
  );
}

/// Puce pour une compétence sans niveau.
pw.Widget _skillChip(String name) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: _chipBg,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(
      name,
      style: pw.TextStyle(fontSize: 10, color: _primaryDark),
    ),
  );
}

/// Carte d'un projet : titre coloré + description, sur fond doux.
pw.Widget _projectCard(String title, String description, List<String> tags) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _cardBg,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _track, width: 0.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _primaryDark,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          description,
          style: pw.TextStyle(fontSize: 10, color: _ink, lineSpacing: 1.5),
        ),
        if (tags.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            tags.join('  ·  '),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _primaryDark,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Une coordonnée de l'en-tête ; cliquable dans un lecteur PDF si [url].
pw.Widget _contactItem(String label, [String? url]) {
  final pw.Widget text = pw.Text(
    label,
    style: pw.TextStyle(color: PdfColor.fromInt(0xFFDBEAFE), fontSize: 10),
  );
  return url == null ? text : pw.UrlLink(destination: url, child: text);
}

/// Une entrée du parcours : intitulé et période, organisation, description,
/// avec un filet coloré à gauche (comme une frise chronologique).
pw.Widget _journeyEntry(ExperienceEntry entry) {
  bool filled(String? v) => v != null && v.trim().isNotEmpty;
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.only(left: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border(left: pw.BorderSide(color: _primary, width: 2)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                entry.title,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
            ),
            if (filled(entry.period)) ...[
              pw.SizedBox(width: 8),
              pw.Text(
                entry.period!.trim(),
                style: pw.TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ],
        ),
        if (filled(entry.organization)) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            entry.organization!.trim(),
            style: pw.TextStyle(fontSize: 10, color: _primaryDark),
          ),
        ],
        if (filled(entry.description)) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            entry.description!.trim(),
            style: pw.TextStyle(fontSize: 10, color: _ink, lineSpacing: 1.5),
          ),
        ],
      ],
    ),
  );
}

/// Pied de page : date de génération à gauche, numéro de page à droite.
pw.Widget _footer(pw.Context context) {
  final now = DateTime.now();
  final String date =
      '${now.year}-${_two(now.month)}-${_two(now.day)}';
  return pw.Container(
    margin: const pw.EdgeInsets.fromLTRB(32, 0, 32, 16),
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _track, width: 0.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('MyPortfolio · $date',
            style: pw.TextStyle(fontSize: 8, color: _muted)),
        pw.Text('${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _muted)),
      ],
    ),
  );
}

/// Formate un nombre sur 2 chiffres (ex : 3 → « 03 ») pour la date.
String _two(int n) => n.toString().padLeft(2, '0');

// --- Caractères compatibles avec la police du PDF ---

/// Équivalents Latin-1 des caractères typographiques courants.
///
/// La police standard du PDF (Helvetica) ne sait dessiner que l'alphabet
/// **Latin-1** (codes 0 à 255 : lettres accentuées françaises comprises). La
/// bibliothèque `pdf` **saute sans erreur** tout autre caractère : sans ce
/// remplacement, « Informatique — IIT Sfax » devenait « Informatique  IIT Sfax ».
/// Le clavier iOS en produit beaucoup (apostrophe ’, guillemets “ ”, tiret —).
const Map<int, String> _latin1Equivalents = {
  0x2010: '-', 0x2011: '-', 0x2012: '-', 0x2013: '-', 0x2014: '-', // tirets
  0x2212: '-', // signe moins
  0x2018: "'", 0x2019: "'", 0x201A: "'", 0x2032: "'", // apostrophes
  0x201C: '"', 0x201D: '"', 0x201E: '"', 0x2033: '"', // guillemets anglais
  0x2026: '...', // points de suspension
  0x2022: '\u00B7', // puce • → point médian ·
  0x2192: '->', 0x2190: '<-', // flèches
  0x0153: 'oe', 0x0152: 'OE', // ligatures œ Œ (absentes de Latin-1)
  0x0178: 'Y', // Ÿ
  0x20AC: 'EUR', // euro
  0x2122: 'TM', // marque
  // Espaces spéciales (l'espace fine insécable précède « ! ? ; » en français).
  0x202F: '\u00A0', 0x2009: ' ', 0x2002: ' ', 0x2003: ' ', 0x2007: ' ',
  0x200B: '', // espace de largeur nulle
};

/// Rend [input] entièrement dessinable par la police du PDF : les caractères
/// typographiques sont remplacés par leur équivalent, ceux qui n'en ont pas
/// (émoji, écritures non latines) sont retirés. Les accents sont conservés.
String pdfSafeText(String input) {
  final StringBuffer out = StringBuffer();
  for (final int rune in input.runes) {
    if (rune <= 0xFF) {
      out.writeCharCode(rune);
    } else {
      out.write(_latin1Equivalents[rune] ?? '');
    }
  }
  return out.toString();
}

/// Copie de [s] dont tous les textes affichés dans le PDF sont « sûrs ».
Student _pdfSafeStudent(Student s) => s.copyWith(
      fullName: pdfSafeText(s.fullName),
      field: pdfSafeText(s.field),
      bio: pdfSafeText(s.bio),
      githubUsername: _safeOrNull(s.githubUsername),
      email: _safeOrNull(s.email),
      phone: _safeOrNull(s.phone),
      linkedin: _safeOrNull(s.linkedin),
      location: _safeOrNull(s.location),
      experiences: [
        for (final e in s.experiences)
          ExperienceEntry(
            id: e.id,
            title: pdfSafeText(e.title),
            organization: _safeOrNull(e.organization),
            period: _safeOrNull(e.period),
            description: _safeOrNull(e.description),
            kind: e.kind,
          ),
      ],
      skills: [
        for (final k in s.skills)
          Skill(
            id: k.id,
            name: pdfSafeText(k.name),
            level: k.level,
            category: k.category,
          ),
      ],
      projects: [
        for (final p in s.projects)
          Project(
            id: p.id,
            title: pdfSafeText(p.title),
            description: pdfSafeText(p.description),
            link: p.link,
            imagePath: p.imagePath,
            tags: [for (final t in p.tags) pdfSafeText(t)],
          ),
      ],
    );

String? _safeOrNull(String? v) => v == null ? null : pdfSafeText(v);
