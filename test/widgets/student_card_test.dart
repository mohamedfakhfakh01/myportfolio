import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio/features/portfolio/presentation/widgets/student_card.dart';
import 'package:myportfolio/l10n/app_localizations.dart';
import 'package:myportfolio/shared/models/student.dart';

/// Enveloppe un widget dans le minimum nécessaire (MaterialApp + traductions)
/// pour qu'il s'affiche en test.
Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('StudentCard affiche le nom et la filière', (tester) async {
    await tester.pumpWidget(_wrap(
      StudentCard(
        student: const Student(
          id: 1,
          fullName: 'Jean Dupont',
          field: 'Informatique',
        ),
        onTap: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.text('Informatique'), findsOneWidget);
  });

  testWidgets('StudentCard : le bouton supprimer déclenche onDelete',
      (tester) async {
    bool deleted = false;
    await tester.pumpWidget(_wrap(
      StudentCard(
        student: const Student(id: 1, fullName: 'Jean Dupont', field: 'Info'),
        onTap: () {},
        onDelete: () => deleted = true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleted, isTrue);
  });

  testWidgets('StudentCard sans onDelete : pas de bouton supprimer',
      (tester) async {
    await tester.pumpWidget(_wrap(
      StudentCard(
        student: const Student(id: 1, fullName: 'Jean Dupont', field: 'Info'),
        onTap: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
