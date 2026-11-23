import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/experience.dart';
import '../../../../shared/widgets/form_sheet.dart';

/// Petit formulaire pour saisir une entrée de parcours (intitulé, organisation,
/// période, description) d'un [ExperienceKind] donné, et la **renvoyer** via
/// `Navigator.pop`, sans toucher à la base de données.
class ExperienceDraftSheet extends StatefulWidget {
  const ExperienceDraftSheet({super.key, required this.kind});

  final ExperienceKind kind;

  @override
  State<ExperienceDraftSheet> createState() => _ExperienceDraftSheetState();
}

class _ExperienceDraftSheetState extends State<ExperienceDraftSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _periodController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _periodController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ExperienceEntry(
        kind: widget.kind,
        title: _titleController.text.trim(),
        organization: _orNull(_orgController.text),
        period: _orNull(_periodController.text),
        description: _orNull(_descController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return FormSheetBody(
      title: l.entryAddTitle,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.titleLabel),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.titleRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _orgController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l.organizationLabel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _periodController,
              decoration: InputDecoration(
                labelText: l.periodLabel,
                hintText: l.periodHint,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.entryDescLabel),
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
