import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/skill.dart';
import '../../../shared/models/student.dart';

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
Future<Uint8List> buildPortfolioPdf(Student student, AppLocalizations l) async {
  final doc = pw.Document();

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

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero, // le bandeau coloré va bord à bord
      footer: (context) => _footer(context),
      build: (context) => [
        _header(student, photo),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(32, 24, 32, 24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- À propos ---
              if (student.bio.isNotEmpty) ...[
                _sectionTitle(l.navAbout),
                pw.Text(
                  student.bio,
                  style: pw.TextStyle(fontSize: 11, color: _ink, lineSpacing: 2),
                ),
                pw.SizedBox(height: 18),
              ],

              // --- Compétences (barres de niveau, puces sinon) ---
              if (student.skills.isNotEmpty) ...[
                _sectionTitle(l.skills),
                _skillsBlock(student.skills),
                pw.SizedBox(height: 6),
              ],

              // --- Projets (en cartes) ---
              if (student.projects.isNotEmpty) ...[
                _sectionTitle(l.projects),
                for (final project in student.projects)
                  _projectCard(
                      project.title, project.description, project.tags),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

/// Bandeau d'en-tête coloré : médaillon (photo ou initiales) + identité.
pw.Widget _header(Student student, pw.MemoryImage? photo) {
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
              if (student.githubUsername != null) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  'GitHub : github.com/${student.githubUsername}',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFFDBEAFE),
                    fontSize: 10,
                  ),
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
              title.toUpperCase(),
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

/// Bloc des compétences : barres de niveau pour celles qui en ont un, puces
/// pour les autres.
pw.Widget _skillsBlock(List<Skill> skills) {
  final withLevel = skills.where((s) => s.level != null).toList();
  final withoutLevel = skills.where((s) => s.level == null).toList();

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final skill in withLevel) _skillWithBar(skill),
        if (withoutLevel.isNotEmpty)
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final s in withoutLevel) _skillChip(s.name)],
          ),
      ],
    ),
  );
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
