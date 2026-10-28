import 'package:flutter/material.dart';

/// Palette de couleurs centralisée de MyPortfolio.
///
/// Toutes les couleurs de l'application sont définies ICI, à un seul endroit.
/// Avantage : si on veut changer la couleur principale, on la modifie une seule
/// fois et toute l'application suit. (Principe « une seule source de vérité ».)
///
/// La classe n'est jamais instanciée : on accède aux couleurs directement par
/// `AppColors.primary`, etc. Le constructeur privé `AppColors._()` empêche de
/// faire `AppColors()` par erreur.
class AppColors {
  AppColors._();

  // --- Couleurs de marque ---
  /// Indigo : couleur principale (barres, boutons, accents forts).
  static const Color primary = Color(0xFF4F46E5);

  /// Indigo foncé : variantes (survol, texte sur fond clair indigo).
  static const Color primaryDark = Color(0xFF4338CA);

  /// Cyan : couleur d'accent secondaire.
  static const Color accent = Color(0xFF06B6D4);

  /// Cyan foncé : texte lisible posé sur un fond cyan clair.
  static const Color accentDark = Color(0xFF0E7490);

  // --- Surfaces ---
  /// Fond général des écrans (gris très clair).
  static const Color background = Color(0xFFF8FAFC);

  /// Fond des cartes et surfaces surélevées (blanc).
  static const Color surface = Color(0xFFFFFFFF);

  // --- Textes ---
  /// Texte principal (gris ardoise très foncé).
  static const Color textPrimary = Color(0xFF1E293B);

  /// Texte secondaire (gris moyen pour les sous-titres, légendes).
  static const Color textSecondary = Color(0xFF64748B);

  // --- Divers ---
  /// Bordures fines (contour des cartes, séparateurs).
  static const Color border = Color(0xFFE2E8F0);

  /// Fond indigo très clair (puces/chips de compétences, icônes douces).
  static const Color primarySoft = Color(0xFFEEF2FF);

  /// Fond cyan très clair (puces/chips d'accent).
  static const Color accentSoft = Color(0xFFCFFAFE);
}
