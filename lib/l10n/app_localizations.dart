import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @remove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get remove;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get navAbout;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @homeHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Les portfolios'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un étudiant pour voir son portfolio'**
  String get homeSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un nom ou une filière…'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour « {query} ».'**
  String noResults(String query);

  /// No description provided for @addCv.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un CV'**
  String get addCv;

  /// No description provided for @emptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun portfolio'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les portfolios des deux étudiants apparaîtront ici.'**
  String get emptyBody;

  /// No description provided for @switchToLight.
  ///
  /// In fr, this message translates to:
  /// **'Passer en thème clair'**
  String get switchToLight;

  /// No description provided for @switchToDark.
  ///
  /// In fr, this message translates to:
  /// **'Passer en thème sombre'**
  String get switchToDark;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @skills.
  ///
  /// In fr, this message translates to:
  /// **'Compétences'**
  String get skills;

  /// No description provided for @projects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get projects;

  /// No description provided for @sortSkills.
  ///
  /// In fr, this message translates to:
  /// **'Trier les compétences'**
  String get sortSkills;

  /// No description provided for @sortProjects.
  ///
  /// In fr, this message translates to:
  /// **'Trier les projets'**
  String get sortProjects;

  /// No description provided for @sortByNameAsc.
  ///
  /// In fr, this message translates to:
  /// **'Nom (A → Z)'**
  String get sortByNameAsc;

  /// No description provided for @sortByLevelDesc.
  ///
  /// In fr, this message translates to:
  /// **'Niveau (élevé → bas)'**
  String get sortByLevelDesc;

  /// No description provided for @sortByTitleAsc.
  ///
  /// In fr, this message translates to:
  /// **'Titre (A → Z)'**
  String get sortByTitleAsc;

  /// No description provided for @sortByTitleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Titre (Z → A)'**
  String get sortByTitleDesc;

  /// No description provided for @addSkill.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une compétence'**
  String get addSkill;

  /// No description provided for @addProject.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un projet'**
  String get addProject;

  /// No description provided for @skillsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune compétence. Appuie sur + pour en ajouter une.'**
  String get skillsEmpty;

  /// No description provided for @skillsHint.
  ///
  /// In fr, this message translates to:
  /// **'Touche une compétence pour la modifier.'**
  String get skillsHint;

  /// No description provided for @projectsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet. Appuie sur + pour en ajouter un.'**
  String get projectsEmpty;

  /// No description provided for @projectsHint.
  ///
  /// In fr, this message translates to:
  /// **'Touche un projet pour le modifier.'**
  String get projectsHint;

  /// No description provided for @githubRepos.
  ///
  /// In fr, this message translates to:
  /// **'Dépôts GitHub'**
  String get githubRepos;

  /// No description provided for @githubNoRepos.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dépôt public trouvé.'**
  String get githubNoRepos;

  /// No description provided for @githubSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count} dépôts · {stars} étoiles'**
  String githubSummary(int count, int stars);

  /// No description provided for @githubMainLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langage principal : {language}'**
  String githubMainLanguage(String language);

  /// No description provided for @githubLastUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : {date}'**
  String githubLastUpdate(String date);

  /// No description provided for @catLanguages.
  ///
  /// In fr, this message translates to:
  /// **'Langages'**
  String get catLanguages;

  /// No description provided for @catFrameworks.
  ///
  /// In fr, this message translates to:
  /// **'Frameworks'**
  String get catFrameworks;

  /// No description provided for @catTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get catTools;

  /// No description provided for @catOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get catOther;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @darkTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get darkTheme;

  /// No description provided for @darkThemeOn.
  ///
  /// In fr, this message translates to:
  /// **'Activé — fond sombre, texte clair'**
  String get darkThemeOn;

  /// No description provided for @darkThemeOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé — fond clair, texte sombre'**
  String get darkThemeOff;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @aboutSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Portfolios étudiants'**
  String get aboutSubtitle;

  /// No description provided for @aboutWhatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce que fait l\'application'**
  String get aboutWhatTitle;

  /// No description provided for @aboutFeature1.
  ///
  /// In fr, this message translates to:
  /// **'Photo, filière et biographie de chaque étudiant'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In fr, this message translates to:
  /// **'Compétences par catégorie, avec niveau'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In fr, this message translates to:
  /// **'Projets réalisés'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In fr, this message translates to:
  /// **'Dépôts GitHub publics (via l\'API GitHub)'**
  String get aboutFeature4;

  /// No description provided for @aboutFeature5.
  ///
  /// In fr, this message translates to:
  /// **'Recherche, tri et thème clair/sombre'**
  String get aboutFeature5;

  /// No description provided for @aboutTechTitle.
  ///
  /// In fr, this message translates to:
  /// **'Technologies'**
  String get aboutTechTitle;

  /// No description provided for @aboutTech1.
  ///
  /// In fr, this message translates to:
  /// **'Flutter & Material 3'**
  String get aboutTech1;

  /// No description provided for @aboutTech2.
  ///
  /// In fr, this message translates to:
  /// **'Base de données locale SQLite (sqflite)'**
  String get aboutTech2;

  /// No description provided for @aboutTech3.
  ///
  /// In fr, this message translates to:
  /// **'API publique GitHub'**
  String get aboutTech3;

  /// No description provided for @aboutFooter.
  ///
  /// In fr, this message translates to:
  /// **'Projet réalisé en 2ᵉ année d\'informatique.'**
  String get aboutFooter;

  /// No description provided for @skillDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la compétence ?'**
  String get skillDeleteTitle;

  /// No description provided for @skillDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » sera supprimée définitivement.'**
  String skillDeleteBody(String name);

  /// No description provided for @skillEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la compétence'**
  String get skillEditTitle;

  /// No description provided for @skillAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une compétence'**
  String get skillAddTitle;

  /// No description provided for @nameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom *'**
  String get nameLabel;

  /// No description provided for @skillNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Flutter'**
  String get skillNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire'**
  String get nameRequired;

  /// No description provided for @levelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau 0–100 (optionnel)'**
  String get levelLabel;

  /// No description provided for @enterNumber.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nombre'**
  String get enterNumber;

  /// No description provided for @between0and100.
  ///
  /// In fr, this message translates to:
  /// **'Entre 0 et 100'**
  String get between0and100;

  /// No description provided for @categoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get categoryLabel;

  /// No description provided for @projectDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le projet ?'**
  String get projectDeleteTitle;

  /// No description provided for @projectDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » sera supprimé définitivement.'**
  String projectDeleteBody(String title);

  /// No description provided for @projectEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le projet'**
  String get projectEditTitle;

  /// No description provided for @projectAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un projet'**
  String get projectAddTitle;

  /// No description provided for @titleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titre *'**
  String get titleLabel;

  /// No description provided for @projectTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : MyPortfolio'**
  String get projectTitleHint;

  /// No description provided for @titleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le titre est obligatoire'**
  String get titleRequired;

  /// No description provided for @descriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description *'**
  String get descriptionLabel;

  /// No description provided for @projectDescHint.
  ///
  /// In fr, this message translates to:
  /// **'Que fait ce projet ?'**
  String get projectDescHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'La description est obligatoire'**
  String get descriptionRequired;

  /// No description provided for @linkLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lien (optionnel)'**
  String get linkLabel;

  /// No description provided for @pickGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get pickGallery;

  /// No description provided for @pickCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get pickCamera;

  /// No description provided for @newPortfolioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau portfolio'**
  String get newPortfolioTitle;

  /// No description provided for @changePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get changePhoto;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get addPhoto;

  /// No description provided for @information.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get information;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet *'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Mohamed Fakhfakh'**
  String get fullNameHint;

  /// No description provided for @fieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Filière / niveau *'**
  String get fieldLabel;

  /// No description provided for @fieldHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : 2e année informatique'**
  String get fieldHint;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'La filière est obligatoire'**
  String get fieldRequired;

  /// No description provided for @bioLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bio (optionnel)'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In fr, this message translates to:
  /// **'Quelques mots sur toi…'**
  String get bioHint;

  /// No description provided for @githubUsernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo GitHub (optionnel)'**
  String get githubUsernameLabel;

  /// No description provided for @githubUsernameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : mohamedfakhfakh01'**
  String get githubUsernameHint;

  /// No description provided for @githubUsernameHelp.
  ///
  /// In fr, this message translates to:
  /// **'Pour afficher tes dépôts GitHub sur le profil'**
  String get githubUsernameHelp;

  /// No description provided for @projectsOptional.
  ///
  /// In fr, this message translates to:
  /// **'Projets (optionnel)'**
  String get projectsOptional;

  /// No description provided for @noProjectAdded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet ajouté. Utilise « Ajouter un projet » ci-dessous.'**
  String get noProjectAdded;

  /// No description provided for @createPortfolio.
  ///
  /// In fr, this message translates to:
  /// **'Créer le portfolio'**
  String get createPortfolio;

  /// No description provided for @exportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportPdf;

  /// No description provided for @pdfError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de générer le PDF.'**
  String get pdfError;

  /// No description provided for @deletePortfolioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le portfolio ?'**
  String get deletePortfolioTitle;

  /// No description provided for @deletePortfolioBody.
  ///
  /// In fr, this message translates to:
  /// **'Le portfolio de « {name} » et toutes ses données seront supprimés définitivement.'**
  String deletePortfolioBody(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
