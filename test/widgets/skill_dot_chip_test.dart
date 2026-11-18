// Tests du chip de compétence à 4 points.
//
// On vérifie surtout la conversion niveau (%) → nombre de points, qui est une
// fonction pure, puis l'affichage du chip.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/portfolio/presentation/widgets/skill_dot_chip.dart';
import 'package:myportfolio/shared/models/skill.dart';

void main() {
  group('skillDots', () {
    test('niveau absent ou nul → 0 point', () {
      expect(skillDots(null), 0);
      expect(skillDots(0), 0);
      expect(skillDots(-10), 0);
    });

    test('les quatre paliers', () {
      expect(skillDots(1), 1);
      expect(skillDots(25), 1);
      expect(skillDots(26), 2);
      expect(skillDots(50), 2);
      expect(skillDots(51), 3);
      expect(skillDots(75), 3);
      expect(skillDots(76), 4);
      expect(skillDots(100), 4);
    });

    test('au-delà de 100 reste plafonné à 4', () {
      expect(skillDots(150), 4);
    });
  });

  group('SkillDotChip', () {
    Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

    testWidgets('affiche le nom de la compétence', (tester) async {
      await tester.pumpWidget(
        wrap(const SkillDotChip(skill: Skill(name: 'Flutter', level: 80))),
      );
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('déclenche onTap au toucher', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrap(SkillDotChip(
          skill: const Skill(name: 'Dart', level: 60),
          onTap: () => tapped = true,
        )),
      );
      await tester.tap(find.text('Dart'));
      expect(tapped, isTrue);
    });
  });
}
