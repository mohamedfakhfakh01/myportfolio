import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
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
  String? _imagePath;

  bool get _hasImage => _imagePath != null && File(_imagePath!).existsSync();

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _linkController = TextEditingController(text: widget.project?.link ?? '');
    _imagePath = widget.project?.imagePath;
  }

  /// Choisit une capture d'écran (galerie ou appareil photo), la copie dans le
  /// dossier de l'app (persistance) et retient son chemin.
  Future<void> _pickImage() async {
    final AppLocalizations l = AppLocalizations.of(context);
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.pickGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.pickCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;
    final Directory dir = await getApplicationDocumentsDirectory();
    final String fileName =
        'project_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final String savedPath = p.join(dir.path, fileName);
    await File(picked.path).copy(savedPath);
    if (!mounted) return;
    setState(() => _imagePath = savedPath);
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

    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final String link = _linkController.text.trim();
    final Project project = Project(
      id: widget.project?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      link: link.isEmpty ? null : link,
      imagePath: _imagePath,
    );

    final provider = context.read<PortfolioProvider>();
    if (_isEditing) {
      await provider.updateProject(project);
    } else {
      await provider.addProject(widget.studentId, project);
    }

    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l.projectSaved)));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.projectDeleteTitle),
        content: Text(l.projectDeleteBody(widget.project!.title)),
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
    await context.read<PortfolioProvider>().deleteProject(widget.project!.id!);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l.projectDeleted)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(_isEditing ? l.projectEditTitle : l.projectAddTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(_hasImage ? l.changePhoto : l.addPhoto),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.titleLabel,
                hintText: l.projectTitleHint,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l.titleRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.descriptionLabel,
                hintText: l.projectDescHint,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l.descriptionRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l.linkLabel,
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
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }
}
