// Briques d'animation partagées (lib/core/widgets/motion.dart) : une animation
// ne doit jamais fausser la donnée affichée, ni bloquer un toucher, et doit
// disparaître quand l'utilisateur demande à réduire les animations.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/core/widgets/motion.dart';

/// Monte [child] ; [reduce] simule le réglage iOS « Réduire les animations ».
Future<void> _pump(WidgetTester tester, Widget child, {bool reduce = false}) =>
    tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: Scaffold(body: child),
      ),
    ));

/// Opacité actuelle de l'EntranceAnimation qui contient [label].
double _opacity(WidgetTester tester, String label) => tester
    .widget<FadeTransition>(find.ancestor(
      of: find.text(label),
      matching: find.byType(FadeTransition),
    ).first)
    .opacity
    .value;

void main() {
  group('CountUpText', () {
    testWidgets('compte de 0 jusqu\'à la valeur EXACTE', (tester) async {
      await _pump(tester, const CountUpText(20));
      expect(find.text('0'), findsOneWidget); // départ

      await tester.pump(const Duration(milliseconds: 200));
      final String milieu =
          tester.widget<Text>(find.byType(Text)).data!;
      expect(int.parse(milieu), inExclusiveRange(0, 20)); // en route

      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget); // arrivée exacte
    });

    testWidgets('suffixe : finit sur « 82% »', (tester) async {
      await _pump(tester, const CountUpText(82, suffix: '%'));
      await tester.pumpAndSettle();
      expect(find.text('82%'), findsOneWidget);
    });

    testWidgets('réduire les animations : valeur exacte tout de suite',
        (tester) async {
      await _pump(tester, const CountUpText(20), reduce: true);
      await tester.pump(); // une seule image
      expect(find.text('20'), findsOneWidget);
    });
  });

  group('EntranceAnimation', () {
    Widget cascade() => Column(children: [
          for (int i = 0; i < 4; i++)
            EntranceAnimation(index: i, child: Text('carte $i')),
        ]);

    testWidgets('cascade : la 1re carte apparaît avant la 4e', (tester) async {
      await _pump(tester, cascade());
      await tester.pump(const Duration(milliseconds: 150));

      final double premiere = _opacity(tester, 'carte 0');
      final double quatrieme = _opacity(tester, 'carte 3');
      expect(premiere, greaterThan(0));
      expect(quatrieme, lessThan(premiere));

      await tester.pumpAndSettle();
      for (int i = 0; i < 4; i++) {
        expect(_opacity(tester, 'carte $i'), 1, reason: 'carte $i');
      }
    });

    testWidgets('réduire les animations : tout est visible d\'emblée',
        (tester) async {
      await _pump(tester, cascade(), reduce: true);
      await tester.pump();
      for (int i = 0; i < 4; i++) {
        expect(_opacity(tester, 'carte $i'), 1, reason: 'carte $i');
      }
    });

    testWidgets('écran quitté en pleine animation : rien ne reste en attente',
        (tester) async {
      await _pump(tester, cascade());
      await tester.pump(const Duration(milliseconds: 100));
      // Remplace l'écran avant la fin : aucun minuteur ne doit traîner (le
      // framework de test échouerait sinon).
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('PressableScale', () {
    testWidgets('s\'enfonce sous le doigt, sans bloquer le toucher',
        (tester) async {
      int taps = 0;
      await _pump(
        tester,
        Center(
          child: PressableScale(
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('carte'),
            ),
          ),
        ),
      );
      double scale() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      final TestGesture doigt =
          await tester.startGesture(tester.getCenter(find.text('carte')));
      await tester.pump();
      expect(scale(), 0.97); // enfoncée

      await doigt.up();
      await tester.pumpAndSettle();
      expect(scale(), 1); // relâchée
      expect(taps, 1); // le toucher est bien passé
    });
  });
}
