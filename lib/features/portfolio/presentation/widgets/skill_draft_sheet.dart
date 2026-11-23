import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/skill.dart';
import '../../../../shared/widgets/form_sheet.dart';
import 'skill_category_label.dart';

/// Petit formulaire pour saisir une compétence (nom, niveau, catégorie) et la
/// **renvoyer** via `Navigator.pop`, sans toucher à la base de données.
class SkillDraftSheet extends StatefulWidget {
  const SkillDraftSheet({super.key});

  @override
  State<SkillDraftSheet> createState() => _SkillDraftSheetState();
}

class _SkillDraftSheetState extends State<SkillDraftSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  SkillCategory _category = SkillCategory.other;

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final String levelText = _levelController.text.trim();
    Navigator.of(context).pop(
      Skill(
        name: _nameController.text.trim(),
        level: levelText.isEmpty ? null : int.parse(levelText),
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return FormSheetBody(
      title: l.skillAddTitle,
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.nameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l.levelLabel),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final int? n = int.tryParse(v.trim());
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l.add),
        ),
      ],
    );
  }
}
