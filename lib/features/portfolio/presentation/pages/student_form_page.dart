import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/motion.dart';
import '../../../github/data/github_repo.dart';
import '../../../github/data/github_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/experience.dart';
import '../../../../shared/models/project.dart';
import '../../../../shared/models/skill.dart';
import '../../../../shared/models/student.dart';
import '../../../../shared/utils/email.dart';
import '../../../../shared/utils/github.dart';
import '../../../../shared/widgets/form_sheet.dart';
import '../../providers/portfolio_provider.dart';
import '../widgets/skill_category_label.dart';
import '../../../github/presentation/widgets/github_account_preview.dart';
import '../widgets/draft_list_section.dart';
import '../widgets/experience_draft_sheet.dart';
import '../widgets/project_draft_sheet.dart';
import '../widgets/skill_draft_sheet.dart';

/// Formulaire plein écran pour créer ou modifier un portfolio étudiant.
class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key, this.student, this.githubService});

  /// L'étudiant à modifier, ou null pour en créer un nouveau.
  final Student? student;

  /// Sert à vérifier que le compte GitHub existe. Injectable pour les tests
  /// (un faux client HTTP, sans réseau) ; sinon le vrai service.
  final GithubService? githubService;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fieldController;
  late final TextEditingController _bioController;
  late final TextEditingController _githubController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _locationController;
  String? _photoPath;

  /// Compétences saisies pendant la création (avant que l'étudiant existe).
  final List<Skill> _skills = [];

  /// Projets saisis pendant la création (avant que l'étudiant existe en base).
  final List<Project> _projects = [];

  /// Parcours saisi pendant la création (expériences et formations).
  final List<ExperienceEntry> _experiences = [];

  bool get _isCreating => widget.student == null;

  late final GithubService _github = widget.githubService ??
      GithubService(timeout: const Duration(seconds: 6));

  /// Clé du champ GitHub : pour le revalider et l'amener à l'écran.
  final _githubFieldKey = GlobalKey<FormFieldState<String>>();

  /// Dernier pseudo que GitHub a déclaré inexistant (affiché en erreur sous
  /// le champ tant qu'il n'est pas modifié).
  String? _githubNotFound;

  // --- Aperçu des dépôts pendant la saisie du pseudo ---

  /// Attente après la dernière touche avant d'interroger GitHub : on ne lance
  /// pas une requête par lettre tapée (limite de 60 requêtes/heure).
  static const Duration _previewDelay = Duration(milliseconds: 700);
  Timer? _previewTimer;

  /// Pseudo pour lequel l'aperçu est affiché (ou en cours de chargement).
  String? _previewUser;
  bool _previewLoading = false;

  /// Dépôts trouvés pour [_previewUser] (null : pas encore, ou échec).
  List<GithubRepo>? _previewRepos;

  /// Vrai si GitHub n'a pas pu répondre (hors ligne, limite atteinte…).
  bool _previewUnknown = false;

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
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _linkedinController =
        TextEditingController(text: widget.student?.linkedin ?? '');
    _locationController =
        TextEditingController(text: widget.student?.location ?? '');
    _photoPath = widget.student?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fieldController.dispose();
    _bioController.dispose();
    _previewTimer?.cancel();
    _githubController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _locationController.dispose();
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
    final Project? project = await showFormSheet<Project>(
      context,
      builder: (_) => const ProjectDraftSheet(),
    );
    if (project != null) setState(() => _projects.add(project));
  }

  /// Ouvre un petit formulaire pour saisir une compétence et l'ajoute à la
  /// liste locale (enregistrée en base au moment de créer le portfolio).
  Future<void> _addSkill() async {
    final Skill? skill = await showFormSheet<Skill>(
      context,
      builder: (_) => const SkillDraftSheet(),
    );
    if (skill != null) setState(() => _skills.add(skill));
  }

  /// Ouvre un formulaire pour saisir une entrée de parcours (du type donné) et
  /// l'ajoute à la liste locale.
  Future<void> _addExperienceEntry(ExperienceKind kind) async {
    final ExperienceEntry? entry = await showFormSheet<ExperienceEntry>(
      context,
      builder: (_) => ExperienceDraftSheet(kind: kind),
    );
    if (entry != null) setState(() => _experiences.add(entry));
  }

  /// Sous-titre d'une entrée : « organisation · période » (ou null si vide).
  String? _experienceMeta(ExperienceEntry e) {
    final parts = [
      if (e.organization != null && e.organization!.isNotEmpty) e.organization!,
      if (e.period != null && e.period!.isNotEmpty) e.period!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Appelé à chaque frappe dans le champ GitHub : efface l'ancien aperçu et
  /// programme une recherche une fois que l'utilisateur a fini de taper.
  void _onGithubChanged(String value) {
    _previewTimer?.cancel();
    if (_githubNotFound != null) {
      _githubNotFound = null;
      _githubFieldKey.currentState!.validate();
    }
    final String? pseudo = githubUsernameFrom(value);
    setState(() {
      _previewUser = null;
      _previewLoading = false;
      _previewRepos = null;
      _previewUnknown = false;
    });
    // Champ vide ou forme impossible : rien à demander à GitHub (le
    // validateur expliquera le problème à l'enregistrement).
    if (pseudo == null || !isValidGithubUsername(pseudo)) return;
    _previewTimer = Timer(_previewDelay, () => _loadPreview(pseudo));
  }

  Future<void> _loadPreview(String pseudo) async {
    setState(() {
      _previewUser = pseudo;
      _previewLoading = true;
    });
    List<GithubRepo>? repos;
    bool notFound = false;
    try {
      repos = await _github.fetchRepos(pseudo, perPage: 100);
    } on GithubException catch (e) {
      notFound = e.notFound;
    }
    // Entre-temps, l'utilisateur a pu modifier le pseudo, ou quitter l'écran :
    // une réponse dépassée est ignorée.
    if (!mounted || _previewUser != pseudo) return;
    setState(() {
      _previewLoading = false;
      _previewRepos = repos;
      _previewUnknown = repos == null && !notFound;
    });
    if (notFound) {
      // Même message que lors de l'enregistrement, directement sous le champ.
      _githubNotFound = pseudo;
      _githubFieldKey.currentState!.validate();
    }
  }

  /// Renvoie le texte nettoyé, ou null s'il est vide.
  String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  /// Vrai pendant l'enregistrement : le bouton « Enregistrer » est désactivé,
  /// sinon un double appui enregistrait deux fois (doublon).
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _doSave();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _doSave() async {
    if (!_formKey.currentState!.validate()) return;

    final AppLocalizations l = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    _previewTimer?.cancel(); // l'enregistrement fait sa propre vérification

    // Une adresse collée en entier est ramenée au pseudo (API + PDF).
    final String? github = githubUsernameFrom(_githubController.text);

    // Le compte existe-t-il ? On ne demande à GitHub que si le pseudo est
    // nouveau ou modifié : modifier sa bio hors ligne ne doit pas attendre le
    // réseau. (GitHub ignore la casse : « Alice » = « alice ».)
    // Si l'aperçu vient de trouver ce compte, inutile de redemander.
    bool githubUnchecked = false;
    final bool alreadyFound = _previewRepos != null && _previewUser == github;
    if (github != null &&
        !alreadyFound &&
        github.toLowerCase() !=
            widget.student?.githubUsername?.toLowerCase()) {
      final GithubUserStatus status = await _github.checkUser(github);
      if (!mounted) return;
      if (status == GithubUserStatus.notFound) {
        _githubNotFound = github;
        _githubFieldKey.currentState!.validate();
        await Scrollable.ensureVisible(
          _githubFieldKey.currentContext!,
          alignment: 0.3,
          duration: const Duration(milliseconds: 300),
        );
        return; // Rien n'est enregistré.
      }
      // Hors ligne : on ne bloque pas, mais on le dit.
      githubUnchecked = status == GithubUserStatus.unknown;
    }

    final Student student = Student(
      id: widget.student?.id,
      fullName: _nameController.text.trim(),
      field: _fieldController.text.trim(),
      bio: _bioController.text.trim(),
      githubUsername: github,
      photoPath: _photoPath,
      email: _orNull(_emailController.text),
      phone: _orNull(_phoneController.text),
      linkedin: _orNull(_linkedinController.text),
      location: _orNull(_locationController.text),
      skills: _isCreating ? _skills : (widget.student?.skills ?? const []),
      projects: widget.student?.projects ?? const [],
      experiences: _isCreating
          ? _experiences
          : (widget.student?.experiences ?? const []),
    );

    final provider = context.read<PortfolioProvider>();
    try {
      if (_isCreating) {
        await provider.addStudent(student, projects: _projects);
      } else {
        await provider.updateStudent(student);
      }
    } on DuplicatePortfolioNameException {
      // Normalement déjà bloqué par le validateur : filet de sécurité.
      messenger.showSnackBar(SnackBar(content: Text(l.nameAlreadyExists)));
      return;
    }
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(
        githubUnchecked ? l.portfolioSavedGithubUnchecked : l.portfolioSaved,
      ),
    ));
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
          // SingleChildScrollView + Column, et non ListView : une ListView
          // détruit les champs sortis de l'écran, qui ne sont alors plus
          // validés. On pouvait ainsi créer un portfolio SANS NOM en faisant
          // défiler jusqu'au bouton avant de valider.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l.nameRequired;
                    }
                    // En modification, garder son propre nom n'est pas un doublon.
                    final bool taken = context
                        .read<PortfolioProvider>()
                        .nameExists(value, excludeId: widget.student?.id);
                    return taken ? l.nameAlreadyExists : null;
                  },
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
                  key: _githubFieldKey,
                  controller: _githubController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l.githubUsernameLabel,
                    hintText: l.githubUsernameHint,
                    helperText: l.githubUsernameHelp,
                    prefixIcon: const Icon(Icons.code),
                  ),
                  // Efface l'erreur éventuelle et relance l'aperçu des dépôts.
                  onChanged: _onGithubChanged,
                  validator: (value) {
                    final String? pseudo = githubUsernameFrom(value ?? '');
                    if (pseudo == null) return null; // champ facultatif
                    if (!isValidGithubUsername(pseudo)) {
                      return l.githubUsernameInvalid;
                    }
                    return pseudo == _githubNotFound
                        ? l.githubUserNotFound
                        : null;
                  },
                ),
                // Fondu entre les états (recherche → trouvé…) et zone qui
                // s'agrandit en douceur au lieu de faire sauter la page.
                AnimatedSize(
                  duration: motionDuration(
                      context, const Duration(milliseconds: 250)),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: motionDuration(
                        context, const Duration(milliseconds: 250)),
                    child: GithubAccountPreview(
                      key: ValueKey<String>(
                        '$_previewUser|$_previewLoading|$_previewUnknown|'
                        '${_previewRepos?.length}',
                      ),
                      loading: _previewLoading,
                      repos: _previewRepos,
                      unknown: _previewUnknown,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Contact (optionnel) ---
                Text(l.contactTitle, style: text.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  // Optionnel, mais s'il est rempli il doit être valide :
                  // il finit dans le CV PDF (lien « écrire »).
                  validator: (value) =>
                      (value == null || value.trim().isEmpty || isValidEmail(value))
                          ? null
                          : l.emailInvalid,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l.phoneLabel,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _linkedinController,
                  decoration: InputDecoration(
                    labelText: l.linkedinLabel,
                    hintText: l.linkedinHint,
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l.locationLabel,
                    hintText: l.locationHint,
                    prefixIcon: const Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 8),

                // --- Contenu (ajouté dès la création) : 4 sections sur le
                // même modèle, un seul widget réutilisable ---
                if (_isCreating) ...[
                  DraftListSection(
                    title: l.skillsOptional,
                    addTooltip: l.addSkill,
                    onAdd: _addSkill,
                    emptyMessage: l.noSkillAdded,
                    items: [
                      for (final Skill s in _skills)
                        DraftListItem(
                          title: s.name,
                          subtitle: s.level != null
                              ? '${skillCategoryLabel(l, s.category)} · ${s.level}%'
                              : skillCategoryLabel(l, s.category),
                          onRemove: () => setState(() => _skills.remove(s)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DraftListSection(
                    title: l.projectsOptional,
                    addTooltip: l.addProject,
                    onAdd: _addProject,
                    emptyMessage: l.noProjectAdded,
                    items: [
                      for (final Project p in _projects)
                        DraftListItem(
                          title: p.title,
                          subtitle: p.description,
                          subtitleMaxLines: 2,
                          onRemove: () => setState(() => _projects.remove(p)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final (kind, title, addTooltip, empty) in [
                    (ExperienceKind.experience, l.experienceTitle,
                        l.addExperience, l.experienceEmpty),
                    (ExperienceKind.education, l.educationTitle,
                        l.addEducation, l.educationEmpty),
                  ]) ...[
                    DraftListSection(
                      title: title,
                      addTooltip: addTooltip,
                      onAdd: () => _addExperienceEntry(kind),
                      emptyMessage: empty,
                      items: [
                        for (final ExperienceEntry e
                            in _experiences.where((e) => e.kind == kind))
                          DraftListItem(
                            title: e.title,
                            subtitle: _experienceMeta(e),
                            onRemove: () =>
                                setState(() => _experiences.remove(e)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                const SizedBox(height: 28),

                // --- Bouton Enregistrer (bien visible) ---
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  // Pendant la vérification GitHub et l'enregistrement : roue.
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
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
      ),
    );
  }
}
