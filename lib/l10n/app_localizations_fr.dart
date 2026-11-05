// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get retry => 'Réessayer';

  @override
  String get remove => 'Retirer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navAbout => 'À propos';

  @override
  String get navSettings => 'Réglages';

  @override
  String get homeHeadline => 'Les portfolios';

  @override
  String get homeSubtitle => 'Choisis un étudiant pour voir son portfolio';

  @override
  String get searchHint => 'Rechercher un nom ou une filière…';

  @override
  String get clear => 'Effacer';

  @override
  String get filterAll => 'Tous';

  @override
  String noResults(String query) {
    return 'Aucun résultat pour « $query ».';
  }

  @override
  String get addCv => 'Ajouter un CV';

  @override
  String get emptyTitle => 'Aucun portfolio';

  @override
  String get emptyBody => 'Les portfolios des deux étudiants apparaîtront ici.';

  @override
  String get switchToLight => 'Passer en thème clair';

  @override
  String get switchToDark => 'Passer en thème sombre';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get skills => 'Compétences';

  @override
  String get projects => 'Projets';

  @override
  String get sortSkills => 'Trier les compétences';

  @override
  String get sortProjects => 'Trier les projets';

  @override
  String get sortByNameAsc => 'Nom (A → Z)';

  @override
  String get sortByLevelDesc => 'Niveau (élevé → bas)';

  @override
  String get sortByTitleAsc => 'Titre (A → Z)';

  @override
  String get sortByTitleDesc => 'Titre (Z → A)';

  @override
  String get addSkill => 'Ajouter une compétence';

  @override
  String get addProject => 'Ajouter un projet';

  @override
  String get skillsEmpty =>
      'Aucune compétence. Appuie sur + pour en ajouter une.';

  @override
  String get skillsHint => 'Touche une compétence pour la modifier.';

  @override
  String get projectsEmpty => 'Aucun projet. Appuie sur + pour en ajouter un.';

  @override
  String get projectsHint => 'Touche un projet pour le modifier.';

  @override
  String get githubRepos => 'Dépôts GitHub';

  @override
  String get githubNoRepos => 'Aucun dépôt public trouvé.';

  @override
  String githubSummary(int count, int stars) {
    return '$count dépôts · $stars étoiles';
  }

  @override
  String githubMainLanguage(String language) {
    return 'Langage principal : $language';
  }

  @override
  String githubLastUpdate(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get catLanguages => 'Langages';

  @override
  String get catFrameworks => 'Frameworks';

  @override
  String get catTools => 'Outils';

  @override
  String get catOther => 'Autres';

  @override
  String get appearance => 'Apparence';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get darkThemeOn => 'Activé — fond sombre, texte clair';

  @override
  String get darkThemeOff => 'Désactivé — fond clair, texte sombre';

  @override
  String get language => 'Langue';

  @override
  String get aboutSubtitle => 'Portfolios étudiants';

  @override
  String get aboutWhatTitle => 'Ce que fait l\'application';

  @override
  String get aboutFeature1 => 'Photo, filière et biographie de chaque étudiant';

  @override
  String get aboutFeature2 => 'Compétences par catégorie, avec niveau';

  @override
  String get aboutFeature3 => 'Projets réalisés';

  @override
  String get aboutFeature4 => 'Dépôts GitHub publics (via l\'API GitHub)';

  @override
  String get aboutFeature5 => 'Recherche, tri et thème clair/sombre';

  @override
  String get aboutTechTitle => 'Technologies';

  @override
  String get aboutTech1 => 'Flutter & Material 3';

  @override
  String get aboutTech2 => 'Base de données locale SQLite (sqflite)';

  @override
  String get aboutTech3 => 'API publique GitHub';

  @override
  String get aboutFooter => 'Projet réalisé en 2ᵉ année d\'informatique.';

  @override
  String get skillDeleteTitle => 'Supprimer la compétence ?';

  @override
  String skillDeleteBody(String name) {
    return '« $name » sera supprimée définitivement.';
  }

  @override
  String get skillEditTitle => 'Modifier la compétence';

  @override
  String get skillAddTitle => 'Ajouter une compétence';

  @override
  String get nameLabel => 'Nom *';

  @override
  String get skillNameHint => 'Ex : Flutter';

  @override
  String get nameRequired => 'Le nom est obligatoire';

  @override
  String get levelLabel => 'Niveau 0–100 (optionnel)';

  @override
  String get enterNumber => 'Entrez un nombre';

  @override
  String get between0and100 => 'Entre 0 et 100';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get projectDeleteTitle => 'Supprimer le projet ?';

  @override
  String projectDeleteBody(String title) {
    return '« $title » sera supprimé définitivement.';
  }

  @override
  String get projectEditTitle => 'Modifier le projet';

  @override
  String get projectAddTitle => 'Ajouter un projet';

  @override
  String get titleLabel => 'Titre *';

  @override
  String get projectTitleHint => 'Ex : MyPortfolio';

  @override
  String get titleRequired => 'Le titre est obligatoire';

  @override
  String get descriptionLabel => 'Description *';

  @override
  String get projectDescHint => 'Que fait ce projet ?';

  @override
  String get descriptionRequired => 'La description est obligatoire';

  @override
  String get linkLabel => 'Lien (optionnel)';

  @override
  String get technologiesLabel => 'Technologies (séparées par des virgules)';

  @override
  String get technologiesHint => 'Ex : Flutter, Dart, Firebase';

  @override
  String get experienceTitle => 'Expérience';

  @override
  String get educationTitle => 'Formation';

  @override
  String get addExperience => 'Ajouter une expérience';

  @override
  String get addEducation => 'Ajouter une formation';

  @override
  String get experienceEmpty =>
      'Aucune expérience. Appuie sur + pour en ajouter.';

  @override
  String get educationEmpty =>
      'Aucune formation. Appuie sur + pour en ajouter.';

  @override
  String get entryAddTitle => 'Ajouter au parcours';

  @override
  String get entryEditTitle => 'Modifier l\'entrée';

  @override
  String get entryKindLabel => 'Type';

  @override
  String get organizationLabel => 'Organisation / établissement';

  @override
  String get periodLabel => 'Période (optionnel)';

  @override
  String get periodHint => 'Ex : 2024 – 2027';

  @override
  String get entryDescLabel => 'Description (optionnel)';

  @override
  String get entryDeleteTitle => 'Supprimer cette entrée ?';

  @override
  String entryDeleteBody(String title) {
    return '« $title » sera supprimé définitivement.';
  }

  @override
  String get entrySaved => 'Parcours enregistré';

  @override
  String get entryDeleted => 'Entrée supprimée';

  @override
  String get pickGallery => 'Galerie';

  @override
  String get pickCamera => 'Appareil photo';

  @override
  String get newPortfolioTitle => 'Nouveau portfolio';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get information => 'Informations';

  @override
  String get fullNameLabel => 'Nom complet *';

  @override
  String get fullNameHint => 'Ex : Mohamed Fakhfakh';

  @override
  String get fieldLabel => 'Filière / niveau *';

  @override
  String get fieldHint => 'Ex : 2e année informatique';

  @override
  String get fieldRequired => 'La filière est obligatoire';

  @override
  String get bioLabel => 'Bio (optionnel)';

  @override
  String get bioHint => 'Quelques mots sur toi…';

  @override
  String get githubUsernameLabel => 'Pseudo GitHub (optionnel)';

  @override
  String get githubUsernameHint => 'Ex : mohamedfakhfakh01';

  @override
  String get githubUsernameHelp =>
      'Pour afficher tes dépôts GitHub sur le profil';

  @override
  String get contactTitle => 'Contact';

  @override
  String get emailLabel => 'E-mail (optionnel)';

  @override
  String get phoneLabel => 'Téléphone (optionnel)';

  @override
  String get linkedinLabel => 'LinkedIn (optionnel)';

  @override
  String get linkedinHint => 'URL ou pseudo LinkedIn';

  @override
  String get locationLabel => 'Localisation (optionnel)';

  @override
  String get locationHint => 'Ex : Sfax, Tunisie';

  @override
  String get skillsOptional => 'Compétences (optionnel)';

  @override
  String get noSkillAdded =>
      'Aucune compétence ajoutée. Utilise « + » ci-dessus.';

  @override
  String get projectsOptional => 'Projets (optionnel)';

  @override
  String get noProjectAdded => 'Aucun projet ajouté. Utilise « + » ci-dessus.';

  @override
  String get createPortfolio => 'Créer le portfolio';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get pdfError => 'Impossible de générer le PDF.';

  @override
  String get deletePortfolioTitle => 'Supprimer le portfolio ?';

  @override
  String deletePortfolioBody(String name) {
    return 'Le portfolio de « $name » et toutes ses données seront supprimés définitivement.';
  }

  @override
  String get viewProject => 'Voir le projet';

  @override
  String get linkError => 'Impossible d\'ouvrir le lien.';

  @override
  String get skillSaved => 'Compétence enregistrée';

  @override
  String get skillDeleted => 'Compétence supprimée';

  @override
  String get projectSaved => 'Projet enregistré';

  @override
  String get projectDeleted => 'Projet supprimé';

  @override
  String get portfolioSaved => 'Portfolio enregistré';

  @override
  String get portfolioDeleted => 'Portfolio supprimé';
}
