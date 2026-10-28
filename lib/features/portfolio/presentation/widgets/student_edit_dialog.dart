import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/models/student.dart';
import '../../providers/portfolio_provider.dart';

/// Ouvre la boîte de dialogue de modification du profil d'un étudiant.
Future<void> showStudentEditDialog(
  BuildContext context, {
  required Student student,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _StudentEditDialog(student: student),
  );
}

class _StudentEditDialog extends StatefulWidget {
  const _StudentEditDialog({required this.student});

  final Student student;

  @override
  State<_StudentEditDialog> createState() => _StudentEditDialogState();
}

class _StudentEditDialogState extends State<_StudentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fieldController;
  late final TextEditingController _bioController;
  late final TextEditingController _githubController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.fullName);
    _fieldController = TextEditingController(text: widget.student.field);
    _bioController = TextEditingController(text: widget.student.bio);
    _githubController =
        TextEditingController(text: widget.student.githubUsername ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fieldController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final String github = _githubController.text.trim();
    // On reconstruit l'étudiant en gardant son id, ses compétences et projets,
    // et en remplaçant les champs du profil.
    final Student updated = Student(
      id: widget.student.id,
      fullName: _nameController.text.trim(),
      field: _fieldController.text.trim(),
      bio: _bioController.text.trim(),
      githubUsername: github.isEmpty ? null : github,
      skills: widget.student.skills,
      projects: widget.student.projects,
    );

    await context.read<PortfolioProvider>().updateStudent(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le profil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        TextButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
