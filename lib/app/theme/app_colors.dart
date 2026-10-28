import 'package:flutter/material.dart';

/// Palette de couleurs centralisée de MyPortfolio — **thème sombre élégant**.
///
/// Toutes les couleurs vivent ICI (principe « une seule source de vérité ») :
/// changer l'accent se fait en un seul endroit, toute l'app suit.
class AppColors {
  AppColors._();

  // --- Couleurs d'accent ---
  /// Bleu : couleur principale (boutons, icônes, avatar, début de dégradé).
  static const Color primary = Color(0xFF3B82F6);

  /// Bleu plus foncé : fin de dégradé, états pressés.
  static const Color primaryDark = Color(0xFF2563EB);

  /// Bleu clair : texte lisible sur les fonds bleus sombres (puces).
  static const Color primaryLight = Color(0xFF93C5FD);

  /// Cyan : accent secondaire.
  static const Color accent = Color(0xFF22D3EE);

  /// Cyan clair : texte/icône d'accent lisible sur fond sombre.
  static const Color accentDark = Color(0xFF67E8F9);

  // --- Surfaces (sombres) ---
  /// Fond général des écrans (bleu anthracite).
  static const Color background = Color(0xFF0F172A);

  /// Fond des cartes et surfaces surélevées (un cran plus clair).
  static const Color surface = Color(0xFF1E293B);

  // --- Textes ---
  /// Texte principal (presque blanc).
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Texte secondaire (gris clair) pour sous-titres et légendes.
  static const Color textSecondary = Color(0xFF94A3B8);

  // --- Divers ---
  /// Bordures fines (gris ardoise) : contour des cartes et champs.
  static const Color border = Color(0xFF334155);

  /// Fond bleu sombre (puces de compétences, icônes douces).
  static const Color primarySoft = Color(0xFF172554);

  /// Fond cyan sombre (puces d'accent).
  static const Color accentSoft = Color(0xFF164E63);
}
