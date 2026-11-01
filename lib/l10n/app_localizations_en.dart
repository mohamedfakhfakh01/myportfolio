// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get retry => 'Retry';

  @override
  String get remove => 'Remove';

  @override
  String get navHome => 'Home';

  @override
  String get navAbout => 'About';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeHeadline => 'The portfolios';

  @override
  String get homeSubtitle => 'Choose a student to view their portfolio';

  @override
  String get searchHint => 'Search by name or field…';

  @override
  String get clear => 'Clear';

  @override
  String noResults(String query) {
    return 'No results for “$query”.';
  }

  @override
  String get addCv => 'Add a CV';

  @override
  String get emptyTitle => 'No portfolio';

  @override
  String get emptyBody => 'The two students\' portfolios will appear here.';

  @override
  String get switchToLight => 'Switch to light theme';

  @override
  String get switchToDark => 'Switch to dark theme';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get skills => 'Skills';

  @override
  String get projects => 'Projects';

  @override
  String get sortSkills => 'Sort skills';

  @override
  String get sortProjects => 'Sort projects';

  @override
  String get sortByNameAsc => 'Name (A → Z)';

  @override
  String get sortByLevelDesc => 'Level (high → low)';

  @override
  String get sortByTitleAsc => 'Title (A → Z)';

  @override
  String get sortByTitleDesc => 'Title (Z → A)';

  @override
  String get addSkill => 'Add a skill';

  @override
  String get addProject => 'Add a project';

  @override
  String get skillsEmpty => 'No skills yet. Tap + to add one.';

  @override
  String get skillsHint => 'Tap a skill to edit it.';

  @override
  String get projectsEmpty => 'No projects yet. Tap + to add one.';

  @override
  String get projectsHint => 'Tap a project to edit it.';

  @override
  String get githubRepos => 'GitHub repositories';

  @override
  String get githubNoRepos => 'No public repository found.';

  @override
  String githubSummary(int count, int stars) {
    return '$count repos · $stars stars';
  }

  @override
  String githubMainLanguage(String language) {
    return 'Main language: $language';
  }

  @override
  String githubLastUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String get catLanguages => 'Languages';

  @override
  String get catFrameworks => 'Frameworks';

  @override
  String get catTools => 'Tools';

  @override
  String get catOther => 'Other';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get darkThemeOn => 'On — dark background, light text';

  @override
  String get darkThemeOff => 'Off — light background, dark text';

  @override
  String get language => 'Language';

  @override
  String get aboutSubtitle => 'Student portfolios';

  @override
  String get aboutWhatTitle => 'What the app does';

  @override
  String get aboutFeature1 => 'Each student\'s photo, field and bio';

  @override
  String get aboutFeature2 => 'Skills by category, with level';

  @override
  String get aboutFeature3 => 'Completed projects';

  @override
  String get aboutFeature4 => 'Public GitHub repositories (via the GitHub API)';

  @override
  String get aboutFeature5 => 'Search, sorting and light/dark theme';

  @override
  String get aboutTechTitle => 'Technologies';

  @override
  String get aboutTech1 => 'Flutter & Material 3';

  @override
  String get aboutTech2 => 'Local SQLite database (sqflite)';

  @override
  String get aboutTech3 => 'Public GitHub API';

  @override
  String get aboutFooter => 'Project made in the 2nd year of computer science.';

  @override
  String get skillDeleteTitle => 'Delete skill?';

  @override
  String skillDeleteBody(String name) {
    return '“$name” will be permanently deleted.';
  }

  @override
  String get skillEditTitle => 'Edit skill';

  @override
  String get skillAddTitle => 'Add a skill';

  @override
  String get nameLabel => 'Name *';

  @override
  String get skillNameHint => 'e.g. Flutter';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get levelLabel => 'Level 0–100 (optional)';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get between0and100 => 'Between 0 and 100';

  @override
  String get categoryLabel => 'Category';

  @override
  String get projectDeleteTitle => 'Delete project?';

  @override
  String projectDeleteBody(String title) {
    return '“$title” will be permanently deleted.';
  }

  @override
  String get projectEditTitle => 'Edit project';

  @override
  String get projectAddTitle => 'Add a project';

  @override
  String get titleLabel => 'Title *';

  @override
  String get projectTitleHint => 'e.g. MyPortfolio';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get descriptionLabel => 'Description *';

  @override
  String get projectDescHint => 'What does this project do?';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get linkLabel => 'Link (optional)';

  @override
  String get pickGallery => 'Gallery';

  @override
  String get pickCamera => 'Camera';

  @override
  String get newPortfolioTitle => 'New portfolio';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get information => 'Information';

  @override
  String get fullNameLabel => 'Full name *';

  @override
  String get fullNameHint => 'e.g. Mohamed Fakhfakh';

  @override
  String get fieldLabel => 'Field / level *';

  @override
  String get fieldHint => 'e.g. 2nd year computer science';

  @override
  String get fieldRequired => 'Field is required';

  @override
  String get bioLabel => 'Bio (optional)';

  @override
  String get bioHint => 'A few words about you…';

  @override
  String get githubUsernameLabel => 'GitHub username (optional)';

  @override
  String get githubUsernameHint => 'e.g. mohamedfakhfakh01';

  @override
  String get githubUsernameHelp =>
      'To show your GitHub repositories on the profile';

  @override
  String get projectsOptional => 'Projects (optional)';

  @override
  String get noProjectAdded => 'No project added. Use “Add a project” below.';

  @override
  String get createPortfolio => 'Create portfolio';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get pdfError => 'Could not generate the PDF.';

  @override
  String get deletePortfolioTitle => 'Delete portfolio?';

  @override
  String deletePortfolioBody(String name) {
    return 'The portfolio of “$name” and all its data will be permanently deleted.';
  }
}
