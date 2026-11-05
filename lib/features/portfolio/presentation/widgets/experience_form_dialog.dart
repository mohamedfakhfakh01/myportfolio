import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/experience.dart';
import '../../providers/portfolio_provider.dart';
import 'experience_kind_label.dart';

/// Ouvre la boîte d'ajout (si [entry] est null) ou de modification d'une entrée
/// de parcours. [defaultKind] pré-sélectionne le type lors d'un ajout.
Future<void> showExperienceFormDialog(
  BuildContext context, {
  required int studentId,
  ExperienceKind defaultKind = ExperienceKind.experience,
  ExperienceEntry? entry,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ExperienceFormDialog(
      studentId: studentId,
      defaultKind: defaultKind,
      entry: entry,
    ),
  );
}

class _ExperienceFormDialog extends StatefulWidget {
  const _ExperienceFormDialog({
    required this.studentId,
    required this.defaultKind,
    this.entry,
  });

  final int studentId;
  final ExperienceKind defaultKind;
  final ExperienceEntry? entry;

  @override
  State<_ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<_ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _orgController;
  late final TextEditingController _periodController;
  late final TextEditingController _descController;
  late ExperienceKind _kind;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _orgController =
        TextEditingController(text: widget.entry?.organization ?? '');
    _periodController = TextEditingController(text: widget.entry?.period ?? '');
    _descController =
        TextEditingController(text: widget.entry?.description ?? '');
    _kind = widget.entry?.kind ?? widget.defaultKind;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _periodController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final ExperienceEntry entry = ExperienceEntry(
      id: widget.entry?.id,
      title: _titleController.text.trim(),
      organization: _orNull(_orgController.text),
      period: _orNull(_periodController.text),
      description: _orNull(_descController.text),
      kind: _kind,
    );

    final provider = context.read<PortfolioProvider>();
    if (_isEditing) {
      await provider.updateExperience(entry);
    } else {
      await provider.addExperience(widget.studentId, entry);
    }

    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l.entrySaved)));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.entryDeleteTitle),
        content: Text(l.entryDeleteBody(widget.entry!.title)),
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
    if (!mounted) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await context.read<PortfolioProvider>().deleteExperience(widget.entry!.id!);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l.entryDeleted)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(_isEditing ? l.entryEditTitle : l.entryAddTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ExperienceKind>(
                initialValue: _kind,
                decoration: InputDecoration(labelText: l.entryKindLabel),
                items: [
                  for (final k in ExperienceKind.values)
                    DropdownMenuItem(
                      value: k,
                      child: Text(experienceKindLabel(l, k)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _kind = value);
                },
              ),
              const SizedBox(height: 12),
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
