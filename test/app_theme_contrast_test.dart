// Les boutons texte et contour doivent rester lisibles dans les deux thèmes,
// sur le fond des écrans comme sur les cartes et feuilles (surface).
// Bug réel : indigo foncé sur fond sombre = 2,3 à 2,8:1 (minimum 4,5:1).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/app/theme/app_colors.dart';
import 'package:myportfolio/app/theme/app_theme.dart';

/// Contraste WCAG entre deux couleurs (1 = aucun, 21 = noir sur blanc).
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Couleur réellement dessinée pour le texte [label].
Color _drawnColor(WidgetTester tester, String label) => tester
    .widget<RichText>(find.descendant(
      of: find.text(label),
      matching: find.byType(RichText),
    ))
    .text
    .style!
    .color!;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('thème ${brightness.name} : boutons texte et contour ≥ 4,5:1',
        (tester) async {
      // Comme l'app : la palette est basculée AVANT de construire le thème.
      AppColors.applyBrightness(brightness);
      addTearDown(() => AppColors.applyBrightness(Brightness.dark));
      final ThemeData theme = AppTheme.themeFor(brightness);

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(children: [
            TextButton(onPressed: () {}, child: const Text('texte')),
            OutlinedButton(onPressed: () {}, child: const Text('contour')),
          ]),
        ),
      ));

      for (final label in ['texte', 'contour']) {
        final Color color = _drawnColor(tester, label);
        for (final (nom, fond) in [
          ('fond', theme.scaffoldBackgroundColor),
          ('surface', AppColors.surface),
        ]) {
          expect(_contrast(color, fond), greaterThanOrEqualTo(4.5),
              reason: 'bouton $label sur $nom ($color sur $fond)');
        }
      }
    });
  }
}
