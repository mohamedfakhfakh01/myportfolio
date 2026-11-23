import 'package:flutter/material.dart';

import '../core/widgets/fade_slide_route.dart';
import '../features/portfolio/presentation/pages/profile_page.dart';
import '../features/portfolio/presentation/pages/project_detail_page.dart';
import '../features/portfolio/presentation/pages/student_form_page.dart';
import '../l10n/app_localizations.dart';
import '../shared/models/student.dart';
import 'main_shell.dart';

/// Arguments de la route [AppRoutes.projet] : quel projet, de quel portfolio.
class ProjectRouteArgs {
  const ProjectRouteArgs({required this.studentId, required this.projectId});

  final int studentId;
  final int projectId;
}

/// **Toutes les routes nommées** de l'application, déclarées à UN seul endroit.
///
/// Analogie : c'est le plan du bâtiment affiché à l'entrée. Chaque écran a une
/// adresse (« /profil », « /projet »…) ; pour y aller, on demande l'adresse
/// (`Navigator.pushNamed`) au lieu de construire l'écran soi-même. Ajouter ou
/// renommer un écran se fait ici, sans toucher aux pages qui y mènent.
///
/// Les arguments sont **vérifiés** : une route appelée sans le bon argument
/// (ou une adresse inconnue) mène à la page « Page introuvable » au lieu de
/// faire planter l'application.
class AppRoutes {
  AppRoutes._(); // pas d'instance : on n'utilise que les constantes.

  /// Coquille à onglets : Accueil / À propos / Réglages.
  static const String accueil = '/';

  /// Page profil d'un portfolio. Argument : son identifiant (`int`).
  static const String profil = '/profil';

  /// Détail d'un projet. Argument : [ProjectRouteArgs].
  static const String projet = '/projet';

  /// Formulaire « Ajouter un CV » (création). Pas d'argument.
  static const String nouveauPortfolio = '/portfolio/nouveau';

  /// Formulaire « Modifier le profil ». Argument : le [Student] à modifier.
  static const String modifierPortfolio = '/portfolio/modifier';

  /// Construit l'écran demandé (branché sur `MaterialApp.onGenerateRoute`).
  /// Renvoie `null` si l'adresse ou l'argument ne correspond pas : Flutter
  /// appelle alors [onUnknownRoute].
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Object? args = settings.arguments;
    switch (settings.name) {
      case accueil:
        // Premier écran : pas d'animation d'entrée.
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainShell(),
        );
      case profil when args is int:
        return fadeSlideRoute(ProfilePage(studentId: args), settings: settings);
      case projet when args is ProjectRouteArgs:
        return fadeSlideRoute(
          ProjectDetailPage(studentId: args.studentId, projectId: args.projectId),
          settings: settings,
        );
      case nouveauPortfolio:
        return fadeSlideRoute(const StudentFormPage(), settings: settings);
      case modifierPortfolio when args is Student:
        return fadeSlideRoute(StudentFormPage(student: args), settings: settings);
    }
    return null;
  }

  /// Adresse inconnue ou argument manquant : page d'erreur avec retour.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(AppLocalizations.of(context).pageNotFound)),
        ),
      );
}
