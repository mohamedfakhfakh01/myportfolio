// Test de widget : PillTag (étiquette en pilule réutilisable du design).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/shared/widgets/pill_tag.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('affiche le libellé', (tester) async {
    await tester.pumpWidget(wrap(const PillTag(label: 'Flutter')));
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('affiche l\'icône quand elle est fournie', (tester) async {
    await tester.pumpWidget(
      wrap(const PillTag(label: 'Dart', icon: Icons.circle)),
    );
    expect(find.text('Dart'), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsOneWidget);
  });

  testWidgets('pas d\'icône par défaut', (tester) async {
    await tester.pumpWidget(wrap(const PillTag(label: 'Git')));
    expect(find.byType(Icon), findsNothing);
  });
}
