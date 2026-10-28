// Test de widget : vérifie l'affichage et l'interaction de SkillChip.
//
// Un test de widget construit un morceau d'interface en mémoire et vérifie ce
// qui est affiché / ce qui se passe au toucher, sans lancer toute l'app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/portfolio/presentation/widgets/skill_chip.dart';
import 'package:myportfolio/shared/models/skill.dart';

void main() {
  // Enveloppe le widget dans un MaterialApp (nécessaire pour les thèmes/polices).
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('affiche le nom seul quand il n\'y a pas de niveau',
      (tester) async {
    await tester.pumpWidget(wrap(const SkillChip(skill: Skill(name: 'Flutter'))));
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('affiche « nom · niveau% » quand un niveau est fourni',
      (tester) async {
    await tester.pumpWidget(
      wrap(const SkillChip(skill: Skill(name: 'Dart', level: 70))),
    );
    expect(find.text('Dart · 70%'), findsOneWidget);
  });

  testWidgets('déclenche onTap au toucher', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(SkillChip(skill: const Skill(name: 'Java'), onTap: () => tapped = true)),
    );
    await tester.tap(find.text('Java'));
    expect(tapped, isTrue);
  });
}
