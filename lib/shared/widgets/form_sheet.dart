import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Ouvre un formulaire dans une **feuille** remontant du bas, avec la même
/// présentation partout : coins arrondis, poignée, fond surface.
///
/// `isScrollControlled` permet à la feuille de dépasser la moitié de l'écran
/// et de remonter au-dessus du clavier.
Future<T?> showFormSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: builder,
  );
}

/// Corps standard d'une feuille de formulaire : un titre, le contenu
/// (défilant si besoin) et une rangée de boutons.
///
/// Une seule source de vérité pour la mise en page : changer l'apparence ici
/// met à jour tous les formulaires de l'app.
class FormSheetBody extends StatelessWidget {
  const FormSheetBody({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
  });

  /// Titre affiché en haut de la feuille.
  final String title;

  /// Contenu du formulaire.
  final Widget content;

  /// Boutons d'action, alignés à droite en bas.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      // Remonte la feuille au-dessus du clavier quand il s'ouvre.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              // Le contenu défile si le formulaire est plus haut que l'écran.
              Flexible(
                child: SingleChildScrollView(child: content),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                // En ligne si les boutons tiennent, empilés sinon (petit
                // écran, texte agrandi, 3 boutons en modification) : une
                // `Row` débordait et poussait « Enregistrer » hors de l'écran.
                Align(
                  alignment: Alignment.centerRight,
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
