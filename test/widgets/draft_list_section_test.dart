// DraftListSection : la section réutilisée 4 fois par le formulaire de
// création (compétences, projets, expérience, formation).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportfolio/features/portfolio/presentation/widgets/draft_list_section.dart';
import 'package:myportfolio/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, DraftListSection section) =>
    tester.pumpWidget(MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: section)),
    ));

void main() {
  testWidgets('liste vide : le message humain, aucune carte', (tester) async {
    await _pump(
      tester,
      DraftListSection(
        title: 'Compétences',
        addTooltip: 'Ajouter',
        onAdd: () {},
        emptyMessage: 'Aucune compétence ajoutée.',
        items: const [],
      ),
    );
    expect(find.text('Aucune compétence ajoutée.'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('une carte par élément ; « + » et « Retirer » appellent les '
      'bonnes actions', (tester) async {
    int ajouts = 0;
    final List<String> retires = [];
    await _pump(
      tester,
      DraftListSection(
        title: 'Projets',
        addTooltip: 'Ajouter un projet',
        onAdd: () => ajouts++,
        emptyMessage: 'vide',
        items: [
          for (final t in ['Blog', 'Appli'])
            DraftListItem(
              title: t,
              subtitle: 'Description de $t',
              onRemove: () => retires.add(t),
            ),
        ],
      ),
    );

    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('vide'), findsNothing);
    expect(find.text('Description de Blog'), findsOneWidget);

    await tester.tap(find.byTooltip('Ajouter un projet'));
    await tester.tap(find.byTooltip('Retirer').last);
    expect(ajouts, 1);
    expect(retires, ['Appli']);
  });
}
