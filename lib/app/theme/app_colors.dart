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

  // --- Surfaces & textes : VARIENT selon le thème (clair/sombre) ---
  //
  // Ces couleurs ne sont PAS `const` : elles sont remplacées par
  // [applyBrightness] quand l'utilisateur bascule le thème. Les ~25 endroits
  // qui écrivent `AppColors.surface`, `AppColors.textSecondary`, etc. n'ont
  // ainsi rien à changer : ils lisent toujours la bonne valeur du moment.
  // (Choix volontairement simple : une seule palette globale commutable.)

  /// Fond général des écrans.
  static Color background = _backgroundDark;

  /// Fond des cartes et surfaces surélevées.
  static Color surface = _surfaceDark;

  /// Texte principal.
  static Color textPrimary = _textPrimaryDark;

  /// Texte secondaire (sous-titres, légendes).
  static Color textSecondary = _textSecondaryDark;

  /// Bordures fines (contour des cartes et champs).
  static Color border = _borderDark;

  /// Fond bleu doux (puces de compétences, icônes douces).
  static Color primarySoft = _primarySoftDark;

  /// Fond cyan doux (puces d'accent).
  static Color accentSoft = _accentSoftDark;

  // Valeurs du thème SOMBRE.
  static const Color _backgroundDark = Color(0xFF0F172A);
  static const Color _surfaceDark = Color(0xFF1E293B);
  static const Color _textPrimaryDark = Color(0xFFF8FAFC);
  static const Color _textSecondaryDark = Color(0xFF94A3B8);
  static const Color _borderDark = Color(0xFF334155);
  static const Color _primarySoftDark = Color(0xFF172554);
  static const Color _accentSoftDark = Color(0xFF164E63);

  // Valeurs du thème CLAIR.
  static const Color _backgroundLight = Color(0xFFF1F5F9);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF0F172A);
  static const Color _textSecondaryLight = Color(0xFF64748B);
  static const Color _borderLight = Color(0xFFE2E8F0);
  static const Color _primarySoftLight = Color(0xFFDBEAFE);
  static const Color _accentSoftLight = Color(0xFFCFFAFE);

  /// Bascule toute la palette des surfaces/textes vers le thème choisi.
  static void applyBrightness(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    background = dark ? _backgroundDark : _backgroundLight;
    surface = dark ? _surfaceDark : _surfaceLight;
    textPrimary = dark ? _textPrimaryDark : _textPrimaryLight;
    textSecondary = dark ? _textSecondaryDark : _textSecondaryLight;
    border = dark ? _borderDark : _borderLight;
    primarySoft = dark ? _primarySoftDark : _primarySoftLight;
    accentSoft = dark ? _accentSoftDark : _accentSoftLight;
  }
}
