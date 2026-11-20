import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Une action rapide : une icône, une info-bulle et ce qu'elle déclenche.
class QuickAction {
  const QuickAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
}

/// Rangée d'**actions rapides** dans un conteneur en pilule (style du design).
///
/// La première action est mise en avant (dégradé indigo → violet, icône
/// blanche) ; les suivantes sont sur fond indigo très doux.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _ActionButton(action: actions[i], highlighted: i == 0),
            ],
          ],
        ),
      ),
    );
  }
}

/// Un bouton carré arrondi d'action rapide.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.highlighted});

  final QuickAction action;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.tooltip,
      child: Material(
        color: highlighted ? Colors.transparent : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: action.onTap,
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: highlighted
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.violet],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              action.icon,
              size: 22,
              color: highlighted ? Colors.white : AppColors.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
