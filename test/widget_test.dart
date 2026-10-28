// Test « fumée » (smoke test) de base de MyPortfolio.
//
// Objectif : vérifier que l'application se construit sans erreur et que
// l'écran de départ s'affiche. (Les vrais tests de fonctionnalités viendront
// plus tard, avec le vrai code.)

import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/app/app.dart';

void main() {
  testWidgets('L\'application démarre et affiche le titre MyPortfolio',
      (WidgetTester tester) async {
    // Construit l'application et déclenche un premier rendu.
    await tester.pumpWidget(const MyPortfolioApp());

    // Le titre « MyPortfolio » (dans l'AppBar) doit être présent à l'écran.
    expect(find.text('MyPortfolio'), findsOneWidget);
  });
}
