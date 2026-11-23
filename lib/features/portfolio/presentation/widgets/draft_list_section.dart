import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Un élément affiché dans une [DraftListSection].
class DraftListItem {
  const DraftListItem({
    required this.title,
    required this.onRemove,
    this.subtitle,
    this.subtitleMaxLines,
  });

  final String title;
  final String? subtitle;

  /// Coupe le sous-titre après ce nombre de lignes (« … »). Null : en entier.
  final int? subtitleMaxLines;

  /// Retire l'élément du brouillon (rien n'est encore en base).
  final VoidCallback onRemove;
}

/// Section du formulaire de création : un titre avec un bouton « + », puis
/// soit un message si la liste est vide, soit une carte par élément avec un
/// bouton « Retirer ».
///
/// Les quatre sections du formulaire (compétences, projets, expérience,
/// formation) avaient chacune leur copie de ce code : un seul widget, quatre
/// utilisations — une correction profite aux quatre.
class DraftListSection extends StatelessWidget {
  const DraftListSection({
    super.key,
    required this.title,
    required this.addTooltip,
    required this.onAdd,
    required this.emptyMessage,
    required this.items,
  });

  final String title;
  final String addTooltip;
  final VoidCallback onAdd;

  /// Texte affiché quand [items] est vide (état vide en langage humain).
  final String emptyMessage;
  final List<DraftListItem> items;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Le titre prend la place restante et passe à la ligne si besoin
            // (texte agrandi en accessibilité) au lieu de pousser le « + »
            // hors de l'écran.
            Expanded(child: Text(title, style: text.titleMedium)),
            IconButton(
              icon: Icon(Icons.add_circle, color: AppColors.primaryText),
              tooltip: addTooltip,
              onPressed: onAdd,
            ),
          ],
        ),
        if (items.isEmpty)
          Text(
            emptyMessage,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          )
        else
          for (final DraftListItem item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: item.subtitle == null
                      ? null
                      : Text(
                          item.subtitle!,
                          maxLines: item.subtitleMaxLines,
                          overflow: item.subtitleMaxLines == null
                              ? null
                              : TextOverflow.ellipsis,
                        ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l.remove,
                    onPressed: item.onRemove,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
