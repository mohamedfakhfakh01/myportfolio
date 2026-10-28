import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/models/project.dart';
import '../../providers/portfolio_provider.dart';

/// Ouvre la boîte de dialogue d'ajout (si [project] est null) ou de modification
/// (si [project] est fourni) d'un projet.
Future<void> showProjectFormDialog(
  BuildContext context, {
  required int studentId,
  Project? project,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ProjectFormDialog(studentId: studentId, project: project),
  );
}

class _ProjectFormDialog extends StatefulWidget {
  const _ProjectFormDialog({required this.studentId, this.project});

  final int studentId;
  final Project? project;

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.project?.description ?? '');
    _linkController = TextEditingController(text: widget.project?.link ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final String link = _linkController.text.trim();
    final Project project = Project(
      id: widget.project?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      link: link.isEmpty ? null : link,
    );

    final provider = context.read<PortfolioProvider>();
    if (_isEditing) {
      await provider.updateProject(project);
    } else {
      await provider.addProject(widget.studentId, project);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le projet ?'),
        content:
            Text('« ${widget.project!.title} » sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<PortfolioProvider>().deleteProject(widget.project!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier le projet' : 'Ajouter un projet'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                hintText: 'Ex : MyPortfolio',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Le titre est obligatoire'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Que fait ce projet ?',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'La description est obligatoire'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Lien (optionnel)',
                hintText: 'https://github.com/...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _delete,
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
