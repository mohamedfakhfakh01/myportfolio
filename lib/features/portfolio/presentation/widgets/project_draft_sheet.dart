import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/widgets/form_sheet.dart';

/// Petit formulaire pour saisir un projet (titre, description, lien) et le
/// **renvoyer** via `Navigator.pop`, sans toucher à la base de données.
class ProjectDraftSheet extends StatefulWidget {
  const ProjectDraftSheet({super.key});

  @override
  State<ProjectDraftSheet> createState() => _ProjectDraftSheetState();
}

class _ProjectDraftSheetState extends State<ProjectDraftSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final String link = _linkController.text.trim();
    final List<String> tags = Project.parseTags(_tagsController.text);
    Navigator.of(context).pop(
      Project(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        link: link.isEmpty ? null : link,
        tags: tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return FormSheetBody(
      title: l.projectAddTitle,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.titleLabel),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.titleRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.descriptionLabel),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.descriptionRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l.linkLabel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.technologiesLabel,
                hintText: l.technologiesHint,
              ),
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
