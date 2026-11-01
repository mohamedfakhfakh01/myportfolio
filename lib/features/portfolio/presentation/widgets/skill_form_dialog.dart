import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/skill.dart';
import '../../providers/portfolio_provider.dart';
import 'skill_category_label.dart';

/// Ouvre la boîte de dialogue d'ajout (si [skill] est null) ou de modification
/// (si [skill] est fourni) d'une compétence.
Future<void> showSkillFormDialog(
  BuildContext context, {
  required int studentId,
  Skill? skill,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SkillFormDialog(studentId: studentId, skill: skill),
  );
}

/// Formulaire d'une compétence. C'est un [StatefulWidget] car il garde l'état
/// de saisie (texte en cours) via des `TextEditingController`.
class _SkillFormDialog extends StatefulWidget {
  const _SkillFormDialog({required this.studentId, this.skill});

  final int studentId;
  final Skill? skill;

  @override
  State<_SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<_SkillFormDialog> {
  // Clé qui permet de déclencher la validation du formulaire.
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _levelController;
  late SkillCategory _category;

  bool get _isEditing => widget.skill != null;

  @override
  void initState() {
    super.initState();
    // Pré-remplit les champs si on modifie une compétence existante.
    _nameController = TextEditingController(text: widget.skill?.name ?? '');
    _levelController =
        TextEditingController(text: widget.skill?.level?.toString() ?? '');
    _category = widget.skill?.category ?? SkillCategory.other;
  }

  @override
  void dispose() {
    // On libère les contrôleurs pour éviter les fuites mémoire.
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // validate() déclenche les `validator` de chaque champ.
    if (!_formKey.currentState!.validate()) return;

    final String levelText = _levelController.text.trim();
    final Skill skill = Skill(
      id: widget.skill?.id,
      name: _nameController.text.trim(),
      level: levelText.isEmpty ? null : int.parse(levelText),
      category: _category,
    );

    final provider = context.read<PortfolioProvider>();
    if (_isEditing) {
      await provider.updateSkill(skill);
    } else {
      await provider.addSkill(widget.studentId, skill);
    }

    // `mounted` : l'écran est-il toujours affiché ? (on vient de faire un await)
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final AppLocalizations l = AppLocalizations.of(context);
    // Confirmation avant une action destructive (bonne pratique).
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.skillDeleteTitle),
        content: Text(l.skillDeleteBody(widget.skill!.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return; // l'écran existe-t-il encore après la confirmation ?
    await context.read<PortfolioProvider>().deleteSkill(widget.skill!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(_isEditing ? l.skillEditTitle : l.skillAddTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.nameLabel,
                hintText: l.skillNameHint,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l.nameRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              // N'autorise que des chiffres au clavier.
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l.levelLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final int? n = int.tryParse(value.trim());
                if (n == null) return l.enterNumber;
                if (n < 0 || n > 100) return l.between0and100;
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SkillCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l.categoryLabel),
              items: [
                for (final c in SkillCategory.values)
                  DropdownMenuItem(
                    value: c,
                    child: Text(skillCategoryLabel(l, c)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _delete,
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _save,
          child: Text(l.save),
        ),
      ],
    );
  }
}
