import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../shared/models/skill.dart';
import '../../providers/portfolio_provider.dart';

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

  bool get _isEditing => widget.skill != null;

  @override
  void initState() {
    super.initState();
    // Pré-remplit les champs si on modifie une compétence existante.
    _nameController = TextEditingController(text: widget.skill?.name ?? '');
    _levelController =
        TextEditingController(text: widget.skill?.level?.toString() ?? '');
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
    // Confirmation avant une action destructive (bonne pratique).
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la compétence ?'),
        content: Text('« ${widget.skill!.name} » sera supprimée définitivement.'),
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
    if (!mounted) return; // l'écran existe-t-il encore après la confirmation ?
    await context.read<PortfolioProvider>().deleteSkill(widget.skill!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Modifier la compétence' : 'Ajouter une compétence',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                hintText: 'Ex : Flutter',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Le nom est obligatoire'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              // N'autorise que des chiffres au clavier.
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Niveau 0–100 (optionnel)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final int? n = int.tryParse(value.trim());
                if (n == null) return 'Entrez un nombre';
                if (n < 0 || n > 100) return 'Entre 0 et 100';
                return null;
              },
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
