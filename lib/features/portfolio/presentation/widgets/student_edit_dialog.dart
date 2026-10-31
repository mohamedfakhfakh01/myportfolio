import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/student.dart';
import '../../providers/portfolio_provider.dart';

/// Ouvre l'**écran plein** d'édition (si [student] est fourni) ou de **création**
/// d'un portfolio (si [student] est null).
///
/// Historiquement c'était une petite boîte de dialogue ; c'est maintenant une
/// page complète, plus claire et plus lisible.
Future<void> showStudentEditDialog(BuildContext context, {Student? student}) {
  return Navigator.of(context).push(
    fadeSlideRoute(StudentFormPage(student: student)),
  );
}

/// Formulaire plein écran pour créer ou modifier un portfolio étudiant.
class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key, this.student});

  /// L'étudiant à modifier, ou null pour en créer un nouveau.
  final Student? student;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fieldController;
  late final TextEditingController _bioController;
  late final TextEditingController _githubController;
  String? _photoPath;

  /// Projets saisis pendant la création (avant que l'étudiant existe en base).
  final List<Project> _projects = [];

  bool get _isCreating => widget.student == null;

  bool get _hasPhoto => _photoPath != null && File(_photoPath!).existsSync();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.student?.fullName ?? '');
    _fieldController = TextEditingController(text: widget.student?.field ?? '');
    _bioController = TextEditingController(text: widget.student?.bio ?? '');
    _githubController =
        TextEditingController(text: widget.student?.githubUsername ?? '');
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

  /// Demande la source de l'image (galerie ou appareil photo).
  Future<ImageSource?> _askSource() {
    final AppLocalizations l = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
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
  }

  /// Choisit la photo de profil (avatar).
  Future<void> _chooseSource() async {
    final ImageSource? source = await _askSource();
    if (source != null) await _pickImage(source);
  }

  /// Sélectionne une image, la **copie** dans le dossier de l'app (persistance),
  /// et retient son chemin.
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

  /// Ouvre un petit formulaire pour saisir un projet et l'ajoute à la liste
  /// locale (il sera enregistré en base au moment de créer le portfolio).
  Future<void> _addProject() async {
    final Project? project = await showDialog<Project>(
      context: context,
      builder: (_) => const _ProjectInputDialog(),
    );
    if (project != null) setState(() => _projects.add(project));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final String github = _githubController.text.trim();
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
      await provider.addStudent(student, projects: _projects);
    } else {
      await provider.updateStudent(student);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreating ? l.newPortfolioTitle : l.editProfile),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // --- Photo de profil ---
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage:
                          _hasPhoto ? FileImage(File(_photoPath!)) : null,
                      child: _hasPhoto
                          ? null
                          : const Icon(Icons.person,
                              color: AppColors.primaryLight, size: 52),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _chooseSource,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(_hasPhoto ? l.changePhoto : l.addPhoto),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Informations ---
              Text(l.information, style: text.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l.fullNameLabel,
                  hintText: l.fullNameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l.nameRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.fieldLabel,
                  hintText: l.fieldHint,
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l.fieldRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.bioLabel,
                  hintText: l.bioHint,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _githubController,
                decoration: InputDecoration(
                  labelText: l.githubUsernameLabel,
                  hintText: l.githubUsernameHint,
                  helperText: l.githubUsernameHelp,
                  prefixIcon: const Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 8),

              // --- Projets (saisis dès la création d'un portfolio) ---
              if (_isCreating) ...[
                Text(l.projectsOptional, style: text.titleMedium),
                const SizedBox(height: 8),
                if (_projects.isEmpty)
                  Text(
                    l.noProjectAdded,
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  )
                else
                  for (int i = 0; i < _projects.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          title: Text(_projects[i].title),
                          subtitle: Text(
                            _projects[i].description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l.remove,
                            onPressed: () =>
                                setState(() => _projects.removeAt(i)),
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addProject,
                  icon: const Icon(Icons.add),
                  label: Text(l.addProject),
                ),
              ],
              const SizedBox(height: 28),

              // --- Bouton Enregistrer (bien visible) ---
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(_isCreating ? l.createPortfolio : l.save),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petit formulaire pour saisir un projet (titre, description, lien) et le
/// **renvoyer** via `Navigator.pop`, sans toucher à la base de données.
class _ProjectInputDialog extends StatefulWidget {
  const _ProjectInputDialog();

  @override
  State<_ProjectInputDialog> createState() => _ProjectInputDialogState();
}

class _ProjectInputDialogState extends State<_ProjectInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final String link = _linkController.text.trim();
    Navigator.of(context).pop(
      Project(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        link: link.isEmpty ? null : link,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.projectAddTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
            ],
          ),
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
