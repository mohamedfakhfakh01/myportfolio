import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/student.dart';
import '../../providers/portfolio_provider.dart';

/// Ouvre la boîte de dialogue d'édition (si [student] est fourni) ou de
/// **création** d'un portfolio (si [student] est null).
Future<void> showStudentEditDialog(BuildContext context, {Student? student}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _StudentEditDialog(student: student),
  );
}

class _StudentEditDialog extends StatefulWidget {
  const _StudentEditDialog({this.student});

  /// L'étudiant à modifier, ou null pour en créer un nouveau.
  final Student? student;

  @override
  State<_StudentEditDialog> createState() => _StudentEditDialogState();
}

class _StudentEditDialogState extends State<_StudentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fieldController;
  late final TextEditingController _bioController;
  late final TextEditingController _githubController;
  String? _photoPath;

  bool get _isCreating => widget.student == null;

  bool get _hasPhoto => _photoPath != null && File(_photoPath!).existsSync();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.student?.fullName ?? '',
    );
    _fieldController = TextEditingController(text: widget.student?.field ?? '');
    _bioController = TextEditingController(text: widget.student?.bio ?? '');
    _githubController = TextEditingController(
      text: widget.student?.githubUsername ?? '',
    );
    _photoPath = widget.student?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fieldController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  /// Propose la source de l'image (galerie ou appareil photo).
  Future<void> _chooseSource() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  /// Sélectionne une image, la **copie** dans le dossier de l'app (pour qu'elle
  /// persiste même si l'original est supprimé), et retient son chemin.
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final Directory dir = await getApplicationDocumentsDirectory();
    final String fileName =
        'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final String savedPath = p.join(dir.path, fileName);
    await File(picked.path).copy(savedPath);

    if (!mounted) return;
    setState(() => _photoPath = savedPath);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final String github = _githubController.text.trim();
    // On (re)construit l'étudiant. En édition, on garde l'id et les listes
    // existantes ; en création, l'id est null et les listes sont vides.
    final Student student = Student(
      id: widget.student?.id,
      fullName: _nameController.text.trim(),
      field: _fieldController.text.trim(),
      bio: _bioController.text.trim(),
      githubUsername: github.isEmpty ? null : github,
      photoPath: _photoPath,
      skills: widget.student?.skills ?? const [],
      projects: widget.student?.projects ?? const [],
    );

    final provider = context.read<PortfolioProvider>();
    if (_isCreating) {
      await provider.addStudent(student);
    } else {
      await provider.updateStudent(student);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCreating ? 'Nouveau portfolio' : 'Modifier le profil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aperçu de la photo (ou icône par défaut) + bouton de choix.
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: _hasPhoto
                    ? FileImage(File(_photoPath!))
                    : null,
                child: _hasPhoto
                    ? null
                    : const Icon(
                        Icons.person,
                        color: AppColors.primaryLight,
                        size: 36,
                      ),
              ),
              TextButton.icon(
                onPressed: _chooseSource,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  _hasPhoto ? 'Changer la photo' : 'Ajouter une photo',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom complet *'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fieldController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Filière / niveau *',
                  hintText: 'Ex : 2e année informatique',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'La filière est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio (optionnel)',
                  hintText: 'Quelques mots sur toi…',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(
                  labelText: 'Pseudo GitHub (optionnel)',
                  hintText: 'Ex : mohamedfakhfakh01',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
