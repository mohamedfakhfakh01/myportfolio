// Audit de lisibilité en thème sombre : aucun texte ni aucune icône ne doit
// être dessiné en indigo foncé (#4F46E5) ou violet foncé (#7C3AED) sur le
// fond sombre — contraste de 2,3 à 3,1:1 seulement (minimum : 4,5:1 pour un
// texte, 3:1 pour une icône). Les FONDS indigo (bouton plein, puce
// sélectionnée) restent permis : le texte posé dessus est blanc.
//
// Bug réel : liens de contact, icônes « + », pilules de catégorie… étaient
// illisibles en plein jour sur iPhone en thème sombre.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myportfolio/app/about_page.dart';
import 'package:myportfolio/app/locale_controller.dart';
import 'package:myportfolio/app/settings_page.dart';
import 'package:myportfolio/app/theme/app_colors.dart';
import 'package:myportfolio/app/theme/app_theme.dart';
import 'package:myportfolio/app/theme/theme_controller.dart';
import 'package:myportfolio/features/portfolio/data/portfolio_repository.dart';
import 'package:myportfolio/features/portfolio/presentation/pages/profile_page.dart';
import 'package:myportfolio/features/portfolio/providers/portfolio_provider.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/experience.dart';
import 'package:myportfolio/shared/models/project.dart';
import 'package:myportfolio/shared/models/skill.dart';
import 'package:myportfolio/shared/models/student.dart';

class _FakeRepo extends PortfolioRepository {
  _FakeRepo(this._students);
  final List<Student> _students;

  @override
  Future<void> seedIfEmpty() async {}

  @override
  Future<List<Student>> getStudents() async => List<Student>.of(_students);
}

/// Profil qui fait apparaître un maximum d'éléments colorés : toutes les
/// catégories de compétences, contact cliquable, projets, expérience,
/// formation. (Pas de pseudo GitHub : aucun appel réseau.)
const Student _complet = Student(
  id: 1,
  fullName: 'Alice Martin',
  field: 'Informatique',
  bio: 'Bio.',
  email: 'alice@example.com',
  phone: '+216 11 222 333',
  linkedin: 'alice',
  location: 'Sfax',
  skills: [
    Skill(name: 'Dart', level: 70, category: SkillCategory.language),
    Skill(name: 'Flutter', level: 80, category: SkillCategory.framework),
    Skill(name: 'Git', level: 60, category: SkillCategory.tool),
    Skill(name: 'Anglais', level: 50, category: SkillCategory.other),
  ],
  projects: [
    Project(id: 10, title: 'Appli', description: 'D.', tags: ['Flutter']),
  ],
  experiences: [
    ExperienceEntry(id: 20, title: 'Stage'),
    ExperienceEntry(id: 21, title: 'Licence', kind: ExperienceKind.education),
  ],
);

final Set<int> _interdites = {
  AppColors.primary.toARGB32(),
  AppColors.violet.toARGB32(),
};

/// Toutes les couleurs de premier plan réellement dessinées (textes, y
/// compris les morceaux de texte enrichi, et icônes), avec ce qu'elles
/// colorent, pour un message d'erreur lisible.
List<(String, Color)> _couleursDessinees(WidgetTester tester) {
  final List<(String, Color)> out = [];
  for (final RichText r in tester.widgetList<RichText>(find.byType(RichText))) {
    r.text.visitChildren((span) {
      final Color? c = span.style?.color;
      if (c != null) out.add(('texte « ${span.toPlainText()} »', c));
      return true;
    });
    final Color? c = r.text.style?.color;
    if (c != null) out.add(('texte « ${r.text.toPlainText()} »', c));
  }
  for (final Icon i in tester.widgetList<Icon>(find.byType(Icon))) {
    if (i.color != null) out.add(('icône ${i.icon?.codePoint}', i.color!));
  }
  return out;
}

Future<void> _pumpSombre(WidgetTester tester, Widget page) async {
  // Le ThemeController applique le thème clair à sa création : on le crée
  // AVANT de basculer la palette en sombre (dans l'app, il est créé une fois
  // au démarrage puis applique le thème enregistré).
  final ThemeController theme = ThemeController();
  AppColors.applyBrightness(Brightness.dark);
  addTearDown(() => AppColors.applyBrightness(Brightness.dark));
  tester.view.physicalSize = const Size(1080, 4800); // tout l'écran visible
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<PortfolioProvider>.value(
        value: PortfolioProvider(repository: _FakeRepo([_complet])),
      ),
      ChangeNotifierProvider<ThemeController>.value(value: theme),
      ChangeNotifierProvider<LocaleController>(
        create: (_) => LocaleController(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.themeFor(Brightness.dark),
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ),
  ));
  await tester.pumpAndSettle();
}

void _aucuneCouleurInterdite(WidgetTester tester) {
  final fautes = [
    for (final (quoi, c) in _couleursDessinees(tester))
      if (_interdites.contains(c.toARGB32())) quoi,
  ];
  expect(fautes, isEmpty,
      reason: 'dessinés en indigo/violet foncé sur fond sombre : $fautes');
}

double _contraste(Color a, Color b) {
  final double la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('Thème sombre : aucun texte ni icône en indigo/violet foncé', () {
    testWidgets('page profil complète', (tester) async {
      await _pumpSombre(tester, const ProfilePage(studentId: 1));
      expect(find.text('Bonjour, Alice'), findsOneWidget); // bien affichée
      _aucuneCouleurInterdite(tester);
    });

    testWidgets('page À propos', (tester) async {
      await _pumpSombre(tester, const AboutPage());
      _aucuneCouleurInterdite(tester);
    });

    testWidgets('page Réglages', (tester) async {
      await _pumpSombre(tester, const Scaffold(body: SettingsPage()));
      _aucuneCouleurInterdite(tester);
    });
  });

  // Les couleurs de remplacement sont-elles vraiment lisibles ? Mesure sur le
  // fond des écrans et sur les cartes, dans les deux thèmes.
  for (final brightness in Brightness.values) {
    test('thème ${brightness.name} : primaryText et violetText ≥ 4,5:1', () {
      AppColors.applyBrightness(brightness);
      addTearDown(() => AppColors.applyBrightness(Brightness.dark));
      for (final (nom, couleur) in [
        ('primaryText', AppColors.primaryText),
        ('violetText', AppColors.violetText),
      ]) {
        for (final (fond, c) in [
          ('fond', AppColors.background),
          ('surface', AppColors.surface),
        ]) {
          expect(_contraste(couleur, c), greaterThanOrEqualTo(4.5),
              reason: '$nom sur $fond');
        }
      }
    });
  }
}
